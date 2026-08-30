# Cloud Build trigger wired directly to the GitHub repo (push to main).
#
# Prereq: connect your GitHub account/repo once via the Cloud Build console
# or `gcloud builds connections` (GitHub App based 2nd-gen connection) —
# Terraform can then reference that connection here.
#
# Set var.github_owner / var.github_repo_name / var.github_connection_name
# in terraform.tfvars once the connection exists.

resource "google_cloudbuild_trigger" "ci_cd" {
  count       = var.enable_cloud_build_trigger ? 1 : 0
  name        = "${var.app_name}-main-push"
  location    = var.region
  description = "Build, test, and deploy the Coin ID system on push to main"

  repository_event_config {
    repository = var.github_connection_name
    push {
      branch = "^main$"
    }
  }

  filename = "ci-cd/cloudbuild.yaml"

  substitutions = {
    _REGION = var.region
    _REPO   = "${var.app_name}-repo"
  }

  service_account = google_service_account.cloud_build_sa[0].id
}

resource "google_service_account" "cloud_build_sa" {
  count        = var.enable_cloud_build_trigger ? 1 : 0
  account_id   = "${var.app_name}-cloudbuild"
  display_name = "Cloud Build CI/CD service account for ${var.app_name}"
}

locals {
  cloud_build_roles = [
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/cloudsql.admin",
    "roles/pubsub.admin",
    "roles/storage.admin",
    "roles/firebasehosting.admin",
    "roles/logging.logWriter",
  ]
}

resource "google_project_iam_member" "cloud_build_sa_roles" {
  for_each = var.enable_cloud_build_trigger ? toset(local.cloud_build_roles) : toset([])
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloud_build_sa[0].email}"
}
