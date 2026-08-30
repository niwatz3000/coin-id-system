"""Thin data-access layer used by the AI Coin Matching Service.

Writes match results back to Cloud SQL (matching_requests, coins_catalog)
and provides the pgvector similarity query used by vector_search.py.
"""
import logging
from contextlib import contextmanager

import psycopg2
import psycopg2.extras

from app.config import settings

logger = logging.getLogger(__name__)


@contextmanager
def get_connection():
    conn = psycopg2.connect(settings.database_url)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def mark_request_processing(matching_request_id: str) -> None:
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            "UPDATE matching_requests SET status = 'PROCESSING' WHERE id = %s",
            (matching_request_id,),
        )


def save_match_result(matching_request_id: str, coin_id: str | None, confidence: float | None,
                       status: str, error_message: str | None = None) -> None:
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            """
            UPDATE matching_requests
            SET status = %s, matched_coin_id = %s, confidence_score = %s,
                error_message = %s, completed_at = now()
            WHERE id = %s
            """,
            (status, coin_id, confidence, error_message, matching_request_id),
        )


def fetch_top_candidates(embedding: list[float], top_k: int):
    """Cosine-similarity search against coins_catalog.embedding (pgvector)."""
    vector_literal = "[" + ",".join(str(x) for x in embedding) + "]"
    with get_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id, coin_name, 1 - (embedding <=> %s::vector) AS similarity
            FROM coins_catalog
            WHERE embedding IS NOT NULL
            ORDER BY embedding <=> %s::vector
            LIMIT %s
            """,
            (vector_literal, vector_literal, top_k),
        )
        return cur.fetchall()
