"""Subscribes to the 'coin-image-uploaded' Pub/Sub topic and runs the
end-to-end matching pipeline: download -> preprocess -> infer -> vector
search -> persist result.
"""
import json
import logging

from google.cloud import pubsub_v1, storage

from app.config import settings
from app.db import mark_request_processing, save_match_result
from app.inference import get_image_embedding
from app.preprocessing import preprocess_image
from app.vector_search import find_best_match

logger = logging.getLogger(__name__)


def _download_image(image_url: str) -> bytes:
    """image_url is expected as gs://<bucket>/<object>."""
    if not image_url.startswith("gs://"):
        raise ValueError(f"Unsupported image URL scheme: {image_url}")

    _, _, rest = image_url.partition("gs://")
    bucket_name, _, blob_name = rest.partition("/")

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    return blob.download_as_bytes()


def handle_message(message: "pubsub_v1.subscriber.message.Message") -> None:
    matching_request_id = "unknown"
    try:
        payload = json.loads(message.data.decode("utf-8"))
        matching_request_id = payload["matchingRequestId"]
        image_url = payload["imageUrl"]

        logger.info("Processing matching request %s (%s)", matching_request_id, image_url)
        mark_request_processing(matching_request_id)

        raw_bytes = _download_image(image_url)
        image = preprocess_image(raw_bytes)
        embedding = get_image_embedding(image)
        coin_id, confidence = find_best_match(embedding)

        status = "MATCHED" if coin_id else "FAILED"
        error = None if coin_id else "No catalog match above confidence threshold"
        save_match_result(matching_request_id, coin_id, confidence, status, error)

        logger.info("Request %s -> %s (coin_id=%s, confidence=%.4f)",
                    matching_request_id, status, coin_id, confidence)
        message.ack()

    except Exception as exc:  # noqa: BLE001
        logger.exception("Failed to process message for request %s", matching_request_id)
        try:
            save_match_result(matching_request_id, None, None, "FAILED", str(exc))
        except Exception:  # noqa: BLE001
            logger.exception("Also failed to persist FAILED status for %s", matching_request_id)
        message.nack()


def run_subscriber() -> None:
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(settings.project_id, settings.pubsub_subscription)

    logger.info("Listening on %s", subscription_path)
    future = subscriber.subscribe(subscription_path, callback=handle_message)

    try:
        future.result()
    except KeyboardInterrupt:
        future.cancel()
        future.result()
