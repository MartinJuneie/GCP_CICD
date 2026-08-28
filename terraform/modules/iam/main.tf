locals {
  app_sa_id      = "sa-${var.environment}-app"
  gke_node_sa_id = "sa-${var.environment}-gke-node"
}

# Dedicated service account for GKE worker nodes
resource "google_service_account" "gke_nodes" {
  account_id   = local.gke_node_sa_id
  display_name = "GKE Node Service Account (${var.environment})"
  project      = var.project_id
}

# Minimal roles for GKE worker nodes
resource "google_project_iam_member" "node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Application Service Account for GKE Workload Identity
resource "google_service_account" "app_sa" {
  account_id   = local.app_sa_id
  display_name = "Application Service Account (${var.environment})"
  project      = var.project_id
}

# Bind K8s Service Account to GCP Service Account
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.app_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
}

# Allow application to read secrets from Secret Manager
resource "google_project_iam_member" "app_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# Allow application to connect to Cloud SQL
resource "google_project_iam_member" "app_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
