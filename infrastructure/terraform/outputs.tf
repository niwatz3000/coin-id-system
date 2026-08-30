output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "coin_images_bucket" {
  value = google_storage_bucket.coin_images.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.coin_image_uploaded.name
}

output "user_catalog_service_url" {
  value = google_cloud_run_v2_service.user_catalog_service.uri
}

output "image_ingestion_service_url" {
  value = google_cloud_run_v2_service.image_ingestion_service.uri
}

output "ai_coin_matching_service_url" {
  value = google_cloud_run_v2_service.ai_coin_matching_service.uri
}

output "cloud_build_service_account_email" {
  value       = var.enable_cloud_build_trigger ? google_service_account.cloud_build_sa[0].email : null
  description = "Grant this SA any additional roles needed by the pipeline"
}
