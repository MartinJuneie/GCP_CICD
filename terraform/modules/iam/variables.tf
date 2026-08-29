variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment identifier (staging, prod)"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
}

variable "k8s_service_account_name" {
  description = "Kubernetes Service Account name"
  type        = string
}
