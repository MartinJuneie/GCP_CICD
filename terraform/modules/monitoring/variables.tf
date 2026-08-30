variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "enable_alerts" {
  description = "Enable creation of monitoring alerting policies"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Optional notification email for monitoring alerts"
  type        = string
  default     = ""
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
