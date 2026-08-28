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
  public_subnet_cidr  = "10.10.0.0/24"
  private_subnet_cidr = "10.10.1.0/24"
  pods_cidr           = "10.11.0.0/21"
  services_cidr       = "10.12.0.0/24"
}

module "cloudsql" {
  source              = "../../modules/cloudsql"
  project_id          = var.project_id
  region              = var.region
  region_short        = var.region_short
  environment         = var.environment
  network_id          = module.vpc.network_id
  database_version    = "POSTGRES_15"
  tier                = "db-custom-1-3840"
  disk_size           = 20
  db_name             = "app_staging_db"
  db_user             = "app_staging_user"
  deletion_protection = false

  depends_on = [module.vpc]
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  region_short  = var.region_short
  repository_id = "test-app"
  description   = "Docker container registry for staging workloads"
}
