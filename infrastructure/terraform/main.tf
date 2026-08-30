terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
    }

  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ============================================================
# REQUIRED APIS
# ============================================================
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "aiplatform.googleapis.com",
    "firebasehosting.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

# ============================================================
# NETWORKING / LOAD BALANCER
# ============================================================
resource "google_compute_global_address" "default" {
  name = "${var.app_name}-lb-ip"
}

# ============================================================
# CLOUD STORAGE - coin images
# ============================================================
resource "google_storage_bucket" "coin_images" {
  name                        = "${var.project_id}-coin-images"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "POST", "PUT"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# ============================================================
# CLOUD SQL - PostgreSQL (pgvector supported via Cloud SQL extension allowlist)
# ============================================================
resource "google_sql_database_instance" "postgres" {
  name             = "${var.app_name}-pg"
  database_version = "POSTGRES_15"
  region            = var.region

  settings {
    tier = var.db_tier
    ip_configuration {
      ipv4_enabled = true
    }
    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "coinid" {
  name     = "coinid"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "coinid" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# ============================================================
# CLOUD PUB/SUB - image upload event bus
# ============================================================
resource "google_pubsub_topic" "coin_image_uploaded" {
  name = "coin-image-uploaded"
}

resource "google_pubsub_subscription" "coin_image_uploaded_sub" {
  name  = "coin-image-uploaded-sub"
  topic = google_pubsub_topic.coin_image_uploaded.id

  ack_deadline_seconds = 60

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "60s"
  }
}

# ============================================================
# ARTIFACT REGISTRY - container images
# ============================================================
resource "google_artifact_registry_repository" "coin_id_repo" {
  location      = var.region
  repository_id = "${var.app_name}-repo"
  format        = "DOCKER"
}

# ============================================================
# CLOUD RUN - User and Catalog Service
# ============================================================
resource "google_cloud_run_v2_service" "user_catalog_service" {
  name     = "${var.app_name}-user-catalog"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo/user-catalog-service:latest"
      env {
        name  = "SPRING_DATASOURCE_URL"
        value = "jdbc:postgresql:///coinid?cloudSqlInstance=${google_sql_database_instance.postgres.connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
      }
    }
  }
}

# ============================================================
# CLOUD RUN - Image Ingestion Service
# ============================================================
resource "google_cloud_run_v2_service" "image_ingestion_service" {
  name     = "${var.app_name}-image-ingestion"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo/image-ingestion-service:latest"
      env {
        name  = "GCS_BUCKET"
        value = google_storage_bucket.coin_images.name
      }
      env {
        name  = "PUBSUB_TOPIC"
        value = google_pubsub_topic.coin_image_uploaded.name
      }
    }
  }
}

# ============================================================
# CLOUD RUN - AI Coin Matching Service
# ============================================================
resource "google_cloud_run_v2_service" "ai_coin_matching_service" {
  name     = "${var.app_name}-ai-matching"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo/ai-coin-matching-service:latest"
      env {
        name  = "PUBSUB_SUBSCRIPTION"
        value = google_pubsub_subscription.coin_image_uploaded_sub.name
      }
      env {
        name  = "VERTEX_AI_ENDPOINT"
        value = var.vertex_ai_endpoint
      }
    }
  }
}

# ============================================================
# FIREBASE HOSTING (frontend) - project must be Firebase-enabled
# ============================================================
resource "google_firebase_hosting_site" "frontend" {
  provider = google-beta
  # provider = google
  project  = var.project_id
  site_id = var.firebase_site_id
  #site_id  = "${var.app_name}-frontend"
}