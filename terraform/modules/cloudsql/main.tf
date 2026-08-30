locals {
  instance_name = "psql-${var.region_short}-${var.project_id}-${var.environment}"
  secret_name   = "sec-${var.environment}-db-credentials"
}

resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "random_password" "db_password" {
  length  = 24
  special = false
}

# Reserve private IP range for VPC peering
resource "google_compute_global_address" "private_ip_address" {
  name          = "ga-${var.environment}-psql-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
  project       = var.project_id
}

# Private Services Access connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "${local.instance_name}-${random_id.db_suffix.hex}"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  deletion_protection = var.deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.tier
    disk_size         = var.disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
      transaction_log_retention_days = 7
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  }
}

# Database
resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# User
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Secret Manager for database credentials
resource "google_secret_manager_secret" "db_credentials" {
  secret_id = local.secret_name
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_credentials_version" {
  secret = google_secret_manager_secret.db_credentials.id
  secret_data = jsonencode({
    host     = google_sql_database_instance.postgres.private_ip_address
    port     = 5432
    database = google_sql_database.db.name
    username = google_sql_user.user.name
    password = random_password.db_password.result
  })
}

