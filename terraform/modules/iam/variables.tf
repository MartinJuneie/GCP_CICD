variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment identifier (staging, prod)"
  type        = string
}

variable "region" {
  description = "GCP region of the shared Artifact Registry repository"
  type        = string
}

variable "shared_artifact_registry_project_id" {
  description = "The shared GCP project ID hosting the pre-created Artifact Registry"
  type        = string
  default     = "cicd-shared-gar-627e"
}

variable "artifact_repository_id" {
  description = "Pre-created Artifact Registry Docker repository ID in the shared project"
  type        = string
  default     = "ar-usc1-test-app"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
}

variable "k8s_service_account_name" {
  description = "Kubernetes Service Account name"
  type        = string
}
