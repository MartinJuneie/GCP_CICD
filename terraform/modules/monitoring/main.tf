resource "google_monitoring_notification_channel" "email" {
  count        = var.enable_alerts && var.notification_email != "" ? 1 : 0
  project      = var.project_id
  display_name = "Alert Email (${var.environment})"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
}

resource "google_monitoring_dashboard" "app_dashboard" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "Application Golden Signals (${var.environment})"
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "HTTP Request Rate (RPS)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"http_external_lb_rule\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["metric.label.response_code_class"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "HTTP Error Rate (4xx & 5xx)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"http_external_lb_rule\" metric.label.response_code_class=monitoring.regex.full_match(\"^[45].*\")"
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "STACKED_BAR"
              }
            ]
          }
        },
        {
          title = "Frontend & Backend Latency (p50, p95, p99)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"loadbalancing.googleapis.com/https/total_latencies\" resource.type=\"http_external_lb_rule\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_DELTA"
                      crossSeriesReducer = "REDUCE_PERCENTILE_99"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Application Pod Restart Count"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/restart_count\" resource.type=\"k8s_container\" resource.label.namespace_name=monitoring.regex.full_match(\"^app-.*\")"
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_DELTA"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        }
      ]
    }
  })
}

resource "google_monitoring_dashboard" "infra_dashboard" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "Infrastructure & Database Health (${var.environment})"
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "GKE Node CPU Utilization (%)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\" resource.type=\"k8s_node\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "GKE Node Memory Utilization (%)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/node/memory/allocatable_utilization\" resource.type=\"k8s_node\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Cloud SQL CPU Utilization (%)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" resource.type=\"cloudsql_database\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Cloud SQL Active Database Connections"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends\" resource.type=\"cloudsql_database\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MAX"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        }
      ]
    }
  })
}

resource "google_monitoring_alert_policy" "high_5xx_error_rate" {
  count        = var.enable_alerts ? 1 : 0
  project      = var.project_id
  display_name = "High 5xx HTTP Error Rate (${var.environment})"
  combiner     = "OR"

  conditions {
    display_name = "HTTP 5xx error count > ${var.error_count_threshold} in 5 min"
    condition_threshold {
      filter          = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"http_external_lb_rule\" metric.label.response_code_class=\"500\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.error_count_threshold
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].name
}

resource "google_monitoring_alert_policy" "high_latency" {
  count        = var.enable_alerts ? 1 : 0
  project      = var.project_id
  display_name = "High Request Latency p95 > ${var.latency_threshold_ms}ms (${var.environment})"
  combiner     = "OR"

  conditions {
    display_name = "Latency p95 exceeds ${var.latency_threshold_ms}ms"
    condition_threshold {
      filter          = "metric.type=\"loadbalancing.googleapis.com/https/total_latencies\" resource.type=\"http_external_lb_rule\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.latency_threshold_ms
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_PERCENTILE_95"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].name
}

resource "google_monitoring_alert_policy" "gke_node_high_cpu" {
  count        = var.enable_alerts ? 1 : 0
  project      = var.project_id
  display_name = "GKE Node High CPU Utilization > ${var.node_cpu_threshold * 100}% (${var.environment})"
  combiner     = "OR"

  conditions {
    display_name = "Node CPU allocatable utilization > ${var.node_cpu_threshold * 100}%"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\" resource.type=\"k8s_node\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.node_cpu_threshold
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].name
}

resource "google_monitoring_alert_policy" "cloudsql_high_cpu" {
  count        = var.enable_alerts ? 1 : 0
  project      = var.project_id
  display_name = "Cloud SQL High CPU Utilization > ${var.cloudsql_cpu_threshold * 100}% (${var.environment})"
  combiner     = "OR"

  conditions {
    display_name = "Cloud SQL CPU utilization > ${var.cloudsql_cpu_threshold * 100}%"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" resource.type=\"cloudsql_database\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.cloudsql_cpu_threshold
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = google_monitoring_notification_channel.email[*].name
}
