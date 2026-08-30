# VPC Outputs
output "vpc_network_id" {
  description = "The unique ID of the staging VPC network"
  value       = module.vpc.network_id
}

output "vpc_network_name" {
  description = "The name of the staging VPC network"
  value       = module.vpc.network_name
}

output "vpc_network_self_link" {
  description = "The URI of the staging VPC network"
  value       = module.vpc.network_self_link
}

output "public_subnet_name" {
  description = "The name of the public subnetwork"
  value       = module.vpc.public_subnet_name
}

output "public_subnet_cidr" {
  description = "The CIDR block for the public subnetwork"
  value       = module.vpc.public_subnet_cidr
}

output "private_subnet_name" {
  description = "The name of the private subnetwork hosting GKE nodes"
  value       = module.vpc.private_subnet_name
}

output "private_subnet_cidr" {
  description = "Primary CIDR block for GKE worker nodes private subnetwork"
  value       = module.vpc.private_subnet_cidr
}

output "pods_range_name" {
  description = "Secondary IP range name configured for GKE Pods"
  value       = module.vpc.pods_range_name
}

output "pods_cidr" {
  description = "Secondary IP CIDR block allocated for GKE Pods"
  value       = module.vpc.pods_cidr
}

output "services_range_name" {
  description = "Secondary IP range name configured for GKE Services"
  value       = module.vpc.services_range_name
}

output "services_cidr" {
  description = "Secondary IP CIDR block allocated for GKE Services"
  value       = module.vpc.services_cidr
}

output "nat_gateway_name" {
  description = "Name of the Cloud NAT gateway providing outbound internet access"
  value       = module.vpc.nat_gateway_name
}

output "ingress_ip_name" {
  description = "Name of the reserved static external IP for ingress"
  value       = module.vpc.ingress_ip_name
}

output "ingress_ip_address" {
  description = "Reserved static external IP address for frontend ingress"
  value       = module.vpc.ingress_ip_address
}

# Cloud SQL Outputs
output "cloudsql_instance_name" {
  description = "Name of the Cloud SQL PostgreSQL instance"
  value       = module.cloudsql.instance_name
}

output "cloudsql_instance_connection" {
  description = "Connection name of the Cloud SQL PostgreSQL instance"
  value       = module.cloudsql.instance_connection_name
}

output "cloudsql_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.cloudsql.private_ip_address
}

output "cloudsql_db_name" {
  description = "Application database name"
  value       = module.cloudsql.db_name
}

output "cloudsql_db_user" {
  description = "Application database user"
  value       = module.cloudsql.db_user
}

output "k8s_db_secret_name" {
  description = "Name of the Kubernetes Secret storing database credentials in the application namespace"
  value       = module.gke.k8s_db_secret_name
}

# GKE Outputs
output "gke_cluster_id" {
  description = "GKE Cluster resource ID"
  value       = module.gke.cluster_id
}

output "gke_cluster_name" {
  description = "GKE Cluster name"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint IP for GKE Cluster master"
  value       = module.gke.cluster_endpoint
}

output "gke_node_service_account" {
  description = "Service account email assigned to GKE worker nodes"
  value       = module.iam.gke_node_service_account_email
}

# IAM Outputs
output "app_service_account_email" {
  description = "Application Service Account email for Workload Identity"
  value       = module.iam.app_service_account_email
}

# Monitoring Outputs
output "app_dashboard_id" {
  description = "Resource ID of the application metrics dashboard"
  value       = module.monitoring.app_dashboard_id
}

output "infra_dashboard_id" {
  description = "Resource ID of the infrastructure and database metrics dashboard"
  value       = module.monitoring.infra_dashboard_id
}
