locals {
  vpc_name            = "vpc-${var.project_id}"
  public_subnet_name  = "sbn-${var.region_short}-${var.project_id}-public"
  private_subnet_name = "sbn-${var.region_short}-${var.project_id}-private-gke"
  pods_range_name     = "rn-pods-${var.region_short}-${var.environment}"
  services_range_name = "rn-services-${var.region_short}-${var.environment}"
  router_name         = "cr-${var.region_short}-${var.environment}-nat"
  nat_name            = "nat-${var.region_short}-${var.environment}-gw"
  fw_internal_name    = "fw-${var.environment}-allow-internal"
  fw_glbc_name        = "fw-${var.environment}-allow-glbc-health-checks"
}

resource "google_compute_network" "vpc_network" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Public subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = local.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

# Private subnet for GKE
resource "google_compute_subnetwork" "private_subnet" {
  name                     = local.private_subnet_name
  ip_cidr_range            = var.private_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  project                  = var.project_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = var.services_cidr
  }
}

# Cloud NAT for private egress
resource "google_compute_router" "nat_router" {
  name    = local.router_name
  region  = var.region
  network = google_compute_network.vpc_network.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = local.nat_name
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Allow internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = local.fw_internal_name
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]
}

# Allow Google health checks
resource "google_compute_firewall" "allow_glbc_health_checks" {
  name    = local.fw_glbc_name
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8000", "8080", "10256"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
}

# Static external IP for Ingress Load Balancer
resource "google_compute_global_address" "ingress_ip" {
  name        = "ip-${var.environment}-ingress"
  description = "Static external IP for frontend GKE ingress load balancer"
  project     = var.project_id
}
