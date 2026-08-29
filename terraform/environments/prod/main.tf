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
    bucket = "gcp-cicd-tfstate-prod"
    prefix = "env/prod"
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
  public_subnet_cidr  = "10.20.0.0/24"
  private_subnet_cidr = "10.20.1.0/24"
  pods_cidr           = "10.21.0.0/21"
  services_cidr       = "10.22.0.0/24"
}

module "cloudsql" {
  source              = "../../modules/cloudsql"
  project_id          = var.project_id
  region              = var.region
  region_short        = var.region_short
  environment         = var.environment
  network_id          = module.vpc.network_id
  database_version    = "POSTGRES_15"
  tier                = "db-custom-2-7680"
  disk_size           = 50
  db_name             = "app_prod_db"
  db_user             = "app_prod_user"
  deletion_protection = true

  depends_on = [module.vpc]
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  region_short  = var.region_short
  repository_id = "test-app"
  description   = "Docker container registry for production workloads"
}

module "iam" {
  source                   = "../../modules/iam"
  project_id               = var.project_id
  environment              = var.environment
  k8s_namespace            = "app-prd"
  k8s_service_account_name = "test-app-sa"
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
  master_ipv4_cidr_block = "172.16.1.0/28"
  node_machine_type      = "e2-standard-4"
  node_service_account   = module.iam.gke_node_service_account_email
  min_node_count         = 2
  max_node_count         = 5
  initial_node_count     = 2
  disk_size_gb           = 50

  depends_on = [module.vpc, module.iam]
}

