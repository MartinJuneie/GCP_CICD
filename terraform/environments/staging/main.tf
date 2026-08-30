terraform {
  required_version = "~> 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

  backend "gcs" {
    bucket = "gcp-cicd-tfstate-staging"
    prefix = "env/staging"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source              = "../../modules/vpc"
  project_id          = var.project_id
  region              = var.region
  region_short        = var.region_short
  environment         = var.environment
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  pods_cidr           = var.pods_cidr
  services_cidr       = var.services_cidr
}

module "cloudsql" {
  source              = "../../modules/cloudsql"
  project_id          = var.project_id
  region              = var.region
  region_short        = var.region_short
  environment         = var.environment
  network_id          = module.vpc.network_id
  database_version    = var.cloudsql_database_version
  tier                = var.cloudsql_tier
  disk_size           = var.cloudsql_disk_size
  db_name             = var.cloudsql_db_name
  db_user             = var.cloudsql_db_user
  deletion_protection = var.cloudsql_deletion_protection

  depends_on = [module.vpc]
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  region_short  = var.region_short
  repository_id = var.artifact_repository_id
  description   = var.artifact_repository_description
}

module "iam" {
  source                   = "../../modules/iam"
  project_id               = var.project_id
  environment              = var.environment
  k8s_namespace            = var.k8s_namespace
  k8s_service_account_name = var.k8s_service_account_name
}

module "gke" {
  source                 = "../../modules/gke"
  project_id             = var.project_id
  region                 = var.region
  region_short           = var.region_short
  environment            = var.environment
  network                = module.vpc.network_name
  subnetwork             = module.vpc.private_subnet_name
  pods_range_name        = module.vpc.pods_range_name
  services_range_name    = module.vpc.services_range_name
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_block
  node_machine_type      = var.gke_node_machine_type
  node_service_account   = module.iam.gke_node_service_account_email
  min_node_count         = var.gke_min_node_count
  max_node_count         = var.gke_max_node_count
  initial_node_count     = var.gke_initial_node_count
  disk_size_gb           = var.gke_disk_size_gb

  depends_on = [module.vpc, module.iam]
}

module "monitoring" {
  source                 = "../../modules/monitoring"
  project_id             = var.project_id
  environment            = var.environment
  enable_alerts          = var.enable_alerts
  error_count_threshold  = var.error_count_threshold
  latency_threshold_ms   = var.latency_threshold_ms
  node_cpu_threshold     = var.node_cpu_threshold
  cloudsql_cpu_threshold = var.cloudsql_cpu_threshold
  notification_email     = var.notification_email
}
