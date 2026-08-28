output "network_id" {
  description = "The unique identifier of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "network_self_link" {
  description = "The URI of the created VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "public_subnet_id" {
  description = "The identifier of the public subnetwork"
  value       = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_name" {
  description = "The name of the public subnetwork"
  value       = google_compute_subnetwork.public_subnet.name
}

output "public_subnet_cidr" {
  description = "The primary IP CIDR block for the public subnetwork"
  value       = google_compute_subnetwork.public_subnet.ip_cidr_range
}

output "private_subnet_id" {
  description = "The identifier of the GKE worker node private subnetwork"
  value       = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_name" {
  description = "The name of the GKE worker node private subnetwork"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_cidr" {
  description = "The primary IP CIDR block for GKE worker nodes private subnetwork"
  value       = google_compute_subnetwork.private_subnet.ip_cidr_range
}

output "pods_range_name" {
  description = "The secondary range name for GKE Pods"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[0].range_name
}

output "pods_cidr" {
  description = "The secondary IP CIDR block allocated for GKE Pods"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[0].ip_cidr_range
}

output "services_range_name" {
  description = "The secondary range name for GKE ClusterIP Services"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[1].range_name
}

output "services_cidr" {
  description = "The secondary IP CIDR block allocated for GKE Services"
  value       = google_compute_subnetwork.private_subnet.secondary_ip_range[1].ip_cidr_range
}

output "router_name" {
  description = "The name of the Cloud Router managing egress"
  value       = google_compute_router.nat_router.name
}

output "nat_gateway_name" {
  description = "The name of the Cloud NAT gateway providing egress for private nodes"
  value       = google_compute_router_nat.nat_gateway.name
}
