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
