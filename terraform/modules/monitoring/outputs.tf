output "app_dashboard_id" {
  description = "Resource ID of the application metrics dashboard"
  value       = google_monitoring_dashboard.app_dashboard.id
}

output "infra_dashboard_id" {
  description = "Resource ID of the infrastructure and database metrics dashboard"
  value       = google_monitoring_dashboard.infra_dashboard.id
}

