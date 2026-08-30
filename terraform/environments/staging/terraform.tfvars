project_id                      = "gcp-cicd-staging"
region                          = "us-central1"
region_short                    = "usc1"
environment                     = "staging"

public_subnet_cidr              = "10.10.0.0/24"
private_subnet_cidr             = "10.10.1.0/24"
pods_cidr                       = "10.11.0.0/21"
services_cidr                   = "10.12.0.0/24"

cloudsql_database_version       = "POSTGRES_15"
cloudsql_tier                   = "db-custom-1-3840"
cloudsql_disk_size              = 20
cloudsql_db_name                = "app_staging_db"
cloudsql_db_user                = "app_staging_user"
cloudsql_deletion_protection    = false

shared_artifact_registry_project_id = "cicd-shared-gar-627e"
artifact_repository_id              = "ar-usc1-test-app"

k8s_namespace                   = "app-stg"
k8s_service_account_name        = "test-app-sa"

gke_master_ipv4_cidr_block      = "172.16.0.0/28"
gke_node_machine_type           = "e2-standard-2"
gke_min_node_count              = 1
gke_max_node_count              = 3
gke_initial_node_count          = 1
gke_disk_size_gb                = 30

enable_alerts                   = false
