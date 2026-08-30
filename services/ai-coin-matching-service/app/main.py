"""AI Coin Matching Service entrypoint.

Exposes a minimal FastAPI app for health checks (required by Cloud Run)
and runs the Pub/Sub subscriber loop in a background thread.
"""
import logging
import threading

from fastapi import FastAPI

from app.subscriber import run_subscriber

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI Coin Matching Service")

_subscriber_thread: threading.Thread | None = None


@app.on_event("startup")
def start_subscriber() -> None:
    global _subscriber_thread
    _subscriber_thread = threading.Thread(target=run_subscriber, daemon=True)
    _subscriber_thread.start()
    logger.info("Pub/Sub subscriber thread started")


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"service": "ai-coin-matching-service", "status": "running"}
