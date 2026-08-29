output "app_service_account_email" {
  description = "Application Service Account email for Workload Identity"
  value       = google_service_account.app_sa.email
}

output "gke_node_service_account_email" {
  description = "GKE Node Service Account email"
  value       = google_service_account.gke_nodes.email
}
