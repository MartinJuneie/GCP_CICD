variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for the resources"
  type        = string
}

variable "region_short" {
  description = "Shorthand code for the region (e.g., usc1 for us-central1)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. staging, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR block for GKE nodes subnet"
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR block for GKE Pods"
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR block for GKE Services"
  type        = string
}
