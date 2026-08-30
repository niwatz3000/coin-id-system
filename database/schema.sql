-- Online Coin Identification & Catalog System - Database Schema
-- PostgreSQL with pgvector extension for AI similarity search

CREATE EXTENSION IF NOT EXISTS pgvector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    role VARCHAR(50) NOT NULL DEFAULT 'USER', -- USER | ADMIN
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- COINS_CATALOG
-- ============================================================
CREATE TABLE IF NOT EXISTS coins_catalog (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coin_name VARCHAR(255) NOT NULL,
    country VARCHAR(100),
    year_minted INT,
    denomination VARCHAR(100),
    material VARCHAR(100),
    mint_mark VARCHAR(50),
    rarity VARCHAR(50),
    description TEXT,
    reference_image_url TEXT,
    embedding vector(512),           -- coin image embedding for similarity search
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_coins_catalog_embedding
    ON coins_catalog USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ============================================================
-- PRICE_HISTORY
-- ============================================================
CREATE TABLE IF NOT EXISTS price_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coin_id UUID NOT NULL REFERENCES coins_catalog(id) ON DELETE CASCADE,
    price NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'USD',
    source VARCHAR(255),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_price_history_coin_id ON price_history(coin_id);

-- ============================================================
-- USER_VIEW_STATS  (for dashboard / analytics)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_view_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    coin_id UUID REFERENCES coins_catalog(id) ON DELETE SET NULL,
    view_count INT NOT NULL DEFAULT 1,
    last_viewed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_view_stats_user_id ON user_view_stats(user_id);

-- ============================================================
-- MATCHING_REQUESTS  (lifecycle of an uploaded image → AI match)
-- ============================================================
CREATE TABLE IF NOT EXISTS matching_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING | PROCESSING | MATCHED | FAILED
    matched_coin_id UUID REFERENCES coins_catalog(id),
    confidence_score NUMERIC(5,4),
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_matching_requests_user_id ON matching_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_matching_requests_status ON matching_requests(status);
