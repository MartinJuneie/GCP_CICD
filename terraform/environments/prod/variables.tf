variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP primary region"
  type        = string
}

variable "region_short" {
  description = "Shorthand code for the region (e.g., usc1)"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnetwork"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnetwork"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR block for GKE pods"
  type        = string
}

variable "services_cidr" {
  description = "CIDR block for GKE services"
  type        = string
}

variable "cloudsql_database_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "POSTGRES_15"
}

variable "cloudsql_tier" {
  description = "Machine tier for Cloud SQL"
  type        = string
}

variable "cloudsql_disk_size" {
  description = "Disk size in GB for Cloud SQL"
  type        = number
}

variable "cloudsql_db_name" {
  description = "Application database name"
  type        = string
}

variable "cloudsql_db_user" {
  description = "Application database username"
  type        = string
}

variable "cloudsql_deletion_protection" {
  description = "Prevent accidental deletion of Cloud SQL instance"
  type        = bool
  default     = true
}

variable "artifact_repository_id" {
  description = "Artifact Registry Docker repository ID"
  type        = string
  default     = "test-app"
}

variable "artifact_repository_description" {
  description = "Artifact Registry description"
  type        = string
  default     = "Docker container registry"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for workload identity"
  type        = string
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "test-app-sa"
}

variable "gke_master_ipv4_cidr_block" {
  description = "CIDR block for GKE control plane"
  type        = string
}

variable "gke_node_machine_type" {
  description = "Machine type for GKE worker nodes"
  type        = string
}

variable "gke_min_node_count" {
  description = "Minimum node count for autoscaling"
  type        = number
}

variable "gke_max_node_count" {
  description = "Maximum node count for autoscaling"
  type        = number
}

variable "gke_initial_node_count" {
  description = "Initial node count"
  type        = number
}

variable "gke_disk_size_gb" {
  description = "Disk size in GB for GKE worker nodes"
  type        = number
  default     = 50
}

variable "enable_alerts" {
  description = "Enable creation of monitoring alerting policies"
  type        = bool
  default     = true
}

variable "error_count_threshold" {
  description = "HTTP 5xx error count threshold for alerting"
  type        = number
  default     = 10
}

variable "latency_threshold_ms" {
  description = "Request latency p95 threshold in milliseconds for alerting"
  type        = number
  default     = 2000
}

variable "node_cpu_threshold" {
  description = "GKE Node CPU utilization threshold (0.0 to 1.0) for alerting"
  type        = number
  default     = 0.85
}

variable "cloudsql_cpu_threshold" {
  description = "Cloud SQL CPU utilization threshold (0.0 to 1.0) for alerting"
  type        = number
  default     = 0.80
}

variable "notification_email" {
  description = "Optional notification email for monitoring alerts"
  type        = string
  default     = ""
}
