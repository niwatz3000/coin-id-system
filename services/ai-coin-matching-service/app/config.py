import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    project_id: str = os.getenv("GOOGLE_CLOUD_PROJECT", "coinid-local")
    pubsub_subscription: str = os.getenv("PUBSUB_SUBSCRIPTION", "coin-image-uploaded-sub")
    database_url: str = os.getenv(
        "DATABASE_URL", "postgresql://coinid:coinid@localhost:5432/coinid"
    )
    vertex_ai_endpoint: str = os.getenv("VERTEX_AI_ENDPOINT", "")
    vertex_ai_region: str = os.getenv("VERTEX_AI_REGION", "asia-southeast1")
    match_score_threshold: float = float(os.getenv("MATCH_SCORE_THRESHOLD", "0.75"))
    top_k: int = int(os.getenv("VECTOR_SEARCH_TOP_K", "5"))


settings = Settings()
