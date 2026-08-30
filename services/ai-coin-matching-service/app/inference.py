"""Runs coin-image embedding inference against a Vertex AI endpoint."""
import base64
import logging

from PIL import Image

from app.config import settings
from app.preprocessing import image_to_bytes

logger = logging.getLogger(__name__)


def get_image_embedding(image: Image.Image) -> list[float]:
    """Sends the preprocessed image to the deployed Vertex AI endpoint and
    returns a fixed-length embedding vector representing the coin image.

    In local/dev environments without a configured endpoint, falls back to
    a deterministic stub embedding so the pipeline can be exercised end to end.
    """
    if not settings.vertex_ai_endpoint:
        logger.warning("VERTEX_AI_ENDPOINT not set — using stub embedding (dev mode)")
        return _stub_embedding(image)

    # Lazy import: keeps local/dev runs light when Vertex AI isn't configured.
    from google.cloud import aiplatform

    aiplatform.init(project=settings.project_id, location=settings.vertex_ai_region)
    endpoint = aiplatform.Endpoint(settings.vertex_ai_endpoint)

    image_b64 = base64.b64encode(image_to_bytes(image)).decode("utf-8")
    prediction = endpoint.predict(instances=[{"image_bytes": {"b64": image_b64}}])

    embedding = prediction.predictions[0].get("embedding")
    if not embedding:
        raise RuntimeError("Vertex AI response did not contain an embedding")
    return embedding


def _stub_embedding(image: Image.Image, dims: int = 512) -> list[float]:
    """Deterministic pseudo-embedding derived from pixel stats — placeholder only.
    TODO: remove once a real Vertex AI endpoint is configured.
    """
    import numpy as np

    arr = np.asarray(image).astype("float32") / 255.0
    flat = arr.mean(axis=(0, 1)).tolist()  # 3 values (R,G,B means)
    rng = np.random.default_rng(seed=int(sum(flat) * 1000))
    vector = rng.normal(loc=sum(flat) / 3, scale=0.1, size=dims)
    norm = np.linalg.norm(vector)
    return (vector / norm).tolist() if norm > 0 else vector.tolist()
