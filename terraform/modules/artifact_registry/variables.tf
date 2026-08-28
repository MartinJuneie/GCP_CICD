variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Artifact Registry"
  type        = string
}

variable "region_short" {
  description = "Shorthand code for the region (e.g., usc1)"
  type        = string
}

variable "repository_id" {
  description = "Repository name identifier in Artifact Registry"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
}

