# Online Coin Identification & Catalog System (MVP 1)

This repository contains the full source scaffold for the **Online Coin Identification & Catalog System**, based on the architecture diagram:

```
[ Mobile / Web Frontend (Angular) ]
                │
                ▼
[ Google Cloud Load Balancer / API Gateway ]
                │
     ┌──────────┴──────────────────────────┐
     ▼                                      ▼
[ User & Coin Catalog Service (Java) ]  [ Image Ingestion Service (Java) ]
     │                                      │
     │ PostgreSQL (Cloud SQL)               ├─► Store raw image -> Cloud Storage
     │                                      │
     └───────────────────┬──────────────────┘
                          │ Event Trigger
                          ▼
                 [ Cloud Pub/Sub ]
                          │
                          ▼
          [ AI Coin Matching Service (Python) ]
                          │
                 Vertex AI / Model Matching
                          │
                          ▼
      [ Write Result -> Cloud SQL / WebSocket to Front-end ]
```

## Repository layout

```
coin-id-system/
├── frontend/                       # Angular SPA (Login, Upload, Matching Result View)
├── services/
│   ├── user-catalog-service/       # Java / Spring Boot - Auth, Admin, Catalog, Dashboard, Analytics
│   ├── image-ingestion-service/    # Java / Spring Boot - Upload API, File Processing, Event Publisher
│   └── ai-coin-matching-service/   # Python - Pub/Sub Subscriber, Preprocessing, Vertex AI Inference, Vector Search
├── infrastructure/terraform/       # Terraform IaC for GCP (Cloud Run, Cloud SQL, Pub/Sub, GCS, LB)
├── database/                       # PostgreSQL schema (pgvector enabled)
├── ci-cd/                          # Cloud Build pipeline (build → test → containerize → terraform apply → deploy)
├── docker-compose.yml              # Local dev stack (Postgres + all 3 services)
└── docs/                           # Architecture notes
```

## Services

| Service | Stack | Responsibilities |
|---|---|---|
| **user-catalog-service** | Java 17 / Spring Boot 3 | Auth (JWT), Admin Panel APIs, Catalog Management, Dashboard, Analytics |
| **image-ingestion-service** | Java 17 / Spring Boot 3 | Upload API, File Processing, publishes events to Cloud Pub/Sub, stores images in GCS |
| **ai-coin-matching-service** | Python 3.11 | Subscribes to Pub/Sub, preprocesses image, runs Vertex AI inference, pgvector similarity search, writes results back to Cloud SQL |
| **frontend** | Angular 17 | Login screen, Upload component, Matching result view |

## Quick start (local)

```bash
# 1. Bring up Postgres + services locally
docker compose up --build

# 2. Frontend dev server
cd frontend
npm install
npm start

# 3. Apply DB schema
psql -h localhost -U coinid -d coinid -f database/schema.sql
```

## Cloud deployment (GCP)

```bash
cd infrastructure/terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

CI/CD is fully GCP-native via **Cloud Build** (`ci-cd/cloudbuild.yaml`): GitHub push → Cloud Build → build/test → Docker build → push to Artifact Registry → `terraform apply` → deploy to Cloud Run / Firebase Hosting. See `ci-cd/README.md` for one-time setup (connecting GitHub, creating the trigger, granting IAM roles).

## Environment variables

See `.env.example` in each service folder for required configuration (DB connection, GCS bucket, Pub/Sub topic, Vertex AI model endpoint, JWT secret).

## Notes

This is an MVP scaffold: business logic (matching algorithm quality, admin UI polish, analytics dashboards) is stubbed with clear `TODO` markers so a team can implement iteratively on top of a working, wired end-to-end pipeline.
