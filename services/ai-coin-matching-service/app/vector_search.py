"""pgvector-backed nearest-neighbour search over coins_catalog."""
import logging

from app.config import settings
from app.db import fetch_top_candidates

logger = logging.getLogger(__name__)


def find_best_match(embedding: list[float]) -> tuple[str | None, float]:
    """Returns (coin_id, confidence) for the closest catalog match,
    or (None, 0.0) if nothing clears the configured similarity threshold.
    """
    candidates = fetch_top_candidates(embedding, settings.top_k)
    if not candidates:
        return None, 0.0

    best = candidates[0]
    similarity = float(best["similarity"])

    if similarity < settings.match_score_threshold:
        logger.info("Best candidate %.4f below threshold %.4f", similarity, settings.match_score_threshold)
        return None, similarity

    return str(best["id"]), similarity
