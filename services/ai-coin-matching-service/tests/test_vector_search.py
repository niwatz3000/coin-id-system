from unittest.mock import patch

from app.vector_search import find_best_match


@patch("app.vector_search.fetch_top_candidates")
def test_find_best_match_returns_coin_above_threshold(mock_fetch):
    mock_fetch.return_value = [
        {"id": "abc-123", "coin_name": "Silver Eagle", "similarity": 0.91},
        {"id": "def-456", "coin_name": "Morgan Dollar", "similarity": 0.80},
    ]

    coin_id, confidence = find_best_match([0.1] * 512)

    assert coin_id == "abc-123"
    assert confidence == 0.91


@patch("app.vector_search.fetch_top_candidates")
def test_find_best_match_returns_none_below_threshold(mock_fetch):
    mock_fetch.return_value = [
        {"id": "abc-123", "coin_name": "Silver Eagle", "similarity": 0.40},
    ]

    coin_id, confidence = find_best_match([0.1] * 512)

    assert coin_id is None
    assert confidence == 0.40


@patch("app.vector_search.fetch_top_candidates")
def test_find_best_match_returns_none_when_no_candidates(mock_fetch):
    mock_fetch.return_value = []

    coin_id, confidence = find_best_match([0.1] * 512)

    assert coin_id is None
    assert confidence == 0.0
