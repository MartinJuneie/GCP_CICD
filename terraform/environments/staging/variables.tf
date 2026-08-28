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
