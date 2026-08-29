variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the GKE cluster"
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

variable "network" {
  description = "VPC network name or self_link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or self_link"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary IP range name for Pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary IP range name for Services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR range for the GKE master endpoint"
  type        = string
}

variable "node_machine_type" {
  description = "Machine type for the worker node pool"
  type        = string
}

variable "node_service_account" {
  description = "Service account email to attach to worker nodes"
  type        = string
}

variable "min_node_count" {
  description = "Minimum node count for autoscaling"
  type        = number
}

variable "max_node_count" {
  description = "Maximum node count for autoscaling"
  type        = number
}

variable "initial_node_count" {
  description = "Initial node count"
  type        = number
}

variable "disk_size_gb" {
  description = "Disk size in GB for worker nodes"
  type        = number
}
