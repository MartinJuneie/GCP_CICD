variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for Cloud SQL"
  type        = string
}

variable "region_short" {
  description = "Shorthand code for the region (e.g., usc1)"
  type        = string
}

variable "environment" {
  description = "Environment identifier (staging, prod)"
  type        = string
}

variable "network_id" {
  description = "The ID of the VPC network to peer with"
  type        = string
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
}

variable "tier" {
  description = "Machine tier for the database instance"
  type        = string
}

variable "disk_size" {
  description = "Initial disk size in GB"
  type        = number
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
}

variable "db_user" {
  description = "Name of the default database user"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to prevent accidental instance deletion"
  type        = bool
}

