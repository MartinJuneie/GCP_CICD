locals {
  repo_id = "cr-${var.region_short}-${var.repository_id}"
}

# Artifact Registry Docker repository
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = local.repo_id
  description   = var.description
  format        = "DOCKER"
  project       = var.project_id

  cleanup_policies {
    id     = "delete-untagged-older-than-7-days"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s"
    }
  }
}
