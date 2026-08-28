terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20.0"
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
  source        = "../../modules/vpc"
  project_id    = var.project_id
  region        = var.region
  region_short  = var.region_short
  environment   = var.environment
  subnet_cidr   = "10.10.1.0/24"
  pods_cidr     = "10.11.0.0/21"
  services_cidr = "10.12.0.0/24"
}
