# CI/CD — Google Cloud Build

This project uses **Cloud Build** (GCP-native) instead of Jenkins. The pipeline
is defined in [`cloudbuild.yaml`](./cloudbuild.yaml):

```
lint/test/build frontend + all 3 services
        │
        ▼
docker build + push to Artifact Registry
        │
        ▼
terraform apply (infra/terraform)
        │
        ▼
deploy 3 services to Cloud Run
        │
        ▼
deploy frontend to Firebase Hosting
```

## One-time setup

1. **Enable APIs** (also handled by Terraform's `google_project_service` block):
   ```bash
   gcloud services enable cloudbuild.googleapis.com run.googleapis.com \
     artifactregistry.googleapis.com sqladmin.googleapis.com \
     pubsub.googleapis.com storage.googleapis.com \
     aiplatform.googleapis.com firebasehosting.googleapis.com
   ```

2. **Connect your GitHub repo to Cloud Build** (2nd-gen, GitHub App based):
   ```bash
   gcloud builds connections create github coin-id-github \
     --region=asia-southeast1

   # Follow the printed URL to authorize the GitHub App, then:
   gcloud builds connections repositories create coin-id-system \
     --connection=coin-id-github \
     --region=asia-southeast1 \
     --remote-uri=https://github.com/<your-username>/<your-repo>.git
   ```

3. **Create the trigger** — either via Terraform (recommended) or manually:

   **Via Terraform** (in `infrastructure/terraform/terraform.tfvars`):
   ```hcl
   enable_cloud_build_trigger = true
   github_connection_name     = "projects/<project>/locations/asia-southeast1/connections/coin-id-github/repositories/coin-id-system"
   ```
   ```bash
   cd infrastructure/terraform
   terraform apply
   ```

   **Or manually:**
   ```bash
   gcloud builds triggers create github \
     --name=coin-id-main-push \
     --repository=projects/<project>/locations/asia-southeast1/connections/coin-id-github/repositories/coin-id-system \
     --branch-pattern="^main$" \
     --build-config=ci-cd/cloudbuild.yaml
   ```

4. **Grant the Cloud Build service account permissions** (Terraform does this
   automatically when `enable_cloud_build_trigger = true`):
   `roles/run.admin`, `roles/iam.serviceAccountUser`, `roles/artifactregistry.writer`,
   `roles/cloudsql.admin`, `roles/pubsub.admin`, `roles/storage.admin`,
   `roles/firebasehosting.admin`.

5. **Secrets**: don't hardcode `_DB_PASSWORD` in the trigger. Store it in
   Secret Manager and reference it in the trigger's substitution, or use
   `availableSecrets` in `cloudbuild.yaml`:
   ```bash
   gcloud secrets create coin-id-db-password --data-file=- <<< "your-password"
   ```

## Manual run (no trigger)

```bash
gcloud builds submit --config ci-cd/cloudbuild.yaml \
  --substitutions=_REGION=asia-southeast1,_REPO=coin-id-repo,_DB_PASSWORD=your-password
```

## Why Cloud Build over Jenkins

- No server to provision, patch, or scale — fully managed.
- Native IAM integration (no service-account key juggling like Jenkins agents need).
- Built-in GitHub App trigger (push/PR) with no webhook plumbing.
- Same billing/project boundary as the rest of the infra (Cloud Run, Artifact
  Registry, Cloud SQL) — one place for logs, quotas, and cost.
