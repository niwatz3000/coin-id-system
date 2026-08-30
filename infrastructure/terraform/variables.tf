variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "app_name" {
  description = "Application name prefix used for resource naming"
  type        = string
  default     = "coin-id"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-1-3840"
}

variable "db_user" {
  description = "Cloud SQL application user"
  type        = string
  default     = "coinid"
}

variable "db_password" {
  description = "Cloud SQL application user password"
  type        = string
  sensitive   = true
}

variable "vertex_ai_endpoint" {
  description = "Vertex AI model endpoint resource name used by the matching service"
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the Cloud SQL instance"
  type        = bool
  default     = true
}

variable "enable_cloud_build_trigger" {
  description = "Whether to create the Cloud Build GitHub push trigger (requires an existing GitHub connection)"
  type        = bool
  default     = false
}

variable "github_connection_name" {
  description = "Fully-qualified Cloud Build 2nd-gen GitHub repository resource name, e.g. projects/PROJECT/locations/REGION/connections/CONN/repositories/REPO"
  type        = string
  default     = ""
}

variable "firebase_site_id" {
  description = "firebase site ID"
  type        = string
  default     = "coin_id_frontend"
}