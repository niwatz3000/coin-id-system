project_id          = "gcp-web-example"
region              = "asia-southeast1"
app_name            = "coin-id-system"
db_tier             = "db-custom-1-3840"
db_user             = "coinid"
db_password         = "P@ssw0rd999"
vertex_ai_endpoint  = "projects/gcp-web-example/locations/asia-southeast1/endpoints/niwatz3000_vertex"
#vertex_ai_endpoint  = "projects/your-project/locations/asia-southeast1/endpoints/your-endpoint-id"
deletion_protection = true

# --- CI/CD (Cloud Build) ---
# Set to true only after creating the GitHub connection (see ci-cd/README.md)
enable_cloud_build_trigger = false

github_connection_name     = "projects/gcp-web-example/locations/asia-southeast1/connections/niwatz3000_1"
#github_connection_name     = "projects/your-project/locations/asia-southeast1/connections/coin-id-github/repositories/coin-id-system"
