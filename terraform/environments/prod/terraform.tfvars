project_id                      = "gcp-cicd-prod"
region                          = "us-central1"
region_short                    = "usc1"
environment                     = "prod"

public_subnet_cidr              = "10.20.0.0/24"
private_subnet_cidr             = "10.20.1.0/24"
pods_cidr                       = "10.21.0.0/21"
services_cidr                   = "10.22.0.0/24"

cloudsql_database_version       = "POSTGRES_15"
cloudsql_tier                   = "db-custom-2-7680"
cloudsql_disk_size              = 50
cloudsql_db_name                = "app_prod_db"
cloudsql_db_user                = "app_prod_user"
cloudsql_deletion_protection    = true

artifact_repository_id          = "test-app"
artifact_repository_description = "Docker container registry for production workloads"

k8s_namespace                   = "app-prd"
k8s_service_account_name        = "test-app-sa"

gke_master_ipv4_cidr_block      = "172.16.1.0/28"
gke_node_machine_type           = "e2-standard-4"
gke_min_node_count              = 2
gke_max_node_count              = 5
gke_initial_node_count          = 2
gke_disk_size_gb                = 50

enable_alerts                   = true
error_count_threshold           = 10
latency_threshold_ms            = 2000
node_cpu_threshold              = 0.85
cloudsql_cpu_threshold          = 0.80
