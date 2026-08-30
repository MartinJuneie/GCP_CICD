output "cluster_id" {
  description = "The GKE cluster ID"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE cluster master"
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "The cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_service_account" {
  description = "Service account email used by GKE worker nodes"
  value       = var.node_service_account
}

output "k8s_namespace" {
  description = "The application Kubernetes namespace"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "k8s_db_secret_name" {
  description = "Name of the Kubernetes Secret storing database credentials"
  value       = kubernetes_secret.db_credentials.metadata[0].name
}
