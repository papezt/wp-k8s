resource "google_monitoring_notification_channel" "john" {
  display_name = "John Doe"
  type         = "email"

  labels = {
    email_address = "john@examplee.id"
  }
}

resource "google_monitoring_uptime_check_config" "https" {
  display_name = "WP uptime check"
  timeout      = "60s"

  http_check = {
    path    = "/"
    port    = "443"
    use_ssl = "true"
  }

  monitored_resource {
    type = "uptime_url"

    labels = {
      project_id = "${var.GOOGLE_PROJECT}"
      host       = "wp.papezt.com"
    }
  }

  content_matchers = {
    content = "WORKS"
  }
}

resource "google_monitoring_alert_policy" "basic_cpu" {
  display_name          = "CPU over 90% for 15 minutes on WP pods"
  combiner              = "OR"
  enabled               = true
  notification_channels = ["${google_monitoring_notification_channel.john.id}"]

  conditions = [
    {
      display_name = "GKE Container - CPU usage for wp by label.pod_id"

      condition_threshold = {
        aggregations = [
          {
            alignment_period     = "60s"
            cross_series_reducer = "REDUCE_MEAN"

            group_by_fields = [
              "resource.label.pod_id",
            ]

            per_series_aligner = "ALIGN_MAX"
          },
        ]

        comparison      = "COMPARISON_GT"
        duration        = "900s"
        filter          = "metric.type=\"container.googleapis.com/container/cpu/utilization\" AND resource.type=\"gke_container\" AND resource.label.container_name=\"wp\" "
        threshold_value = 0.9

        trigger = {
          count = 1
        }
      }
    },
  ]
}

resource "google_monitoring_alert_policy" "basic_mem" {
  display_name          = "Memory over 80M for 15 minutes on WP"
  combiner              = "OR"
  enabled               = true
  notification_channels = ["${google_monitoring_notification_channel.john.id}"]

  conditions = [
    {
      display_name = "GKE Container - Memory usage for wp by label.pod_id"

      condition_threshold = {
        aggregations = [
          {
            alignment_period     = "60s"
            cross_series_reducer = "REDUCE_MEAN"

            group_by_fields = [
              "resource.label.pod_id",
            ]

            per_series_aligner = "ALIGN_MAX"
          },
        ]

        comparison      = "COMPARISON_GT"
        duration        = "900s"
        filter          = "metric.type=\"container.googleapis.com/container/memory/bytes_used\" AND resource.type=\"gke_container\" AND resource.label.container_name=\"wp\" "
        threshold_value = 100000000

        trigger = {
          count = 1
        }
      }
    },
  ]
}

resource "google_monitoring_alert_policy" "db_up" {
  display_name          = "DB wp is UP"
  combiner              = "OR"
  enabled               = true
  notification_channels = ["${google_monitoring_notification_channel.john.id}"]

  conditions = [
    {
      display_name = "Database is UP"

      condition_threshold = {
        aggregations = [
          {
            alignment_period = "60s"

            per_series_aligner = "ALIGN_MEAN"
          },
        ]

        comparison      = "COMPARISON_LT"
        duration        = "60s"
        filter          = "metric.type=\"cloudsql.googleapis.com/database/up\" resource.type=\"cloudsql_database\" metadata.system_labels.name=\"wordpress-testing\""
        threshold_value = 1.0

        trigger = {
          count = 1
        }
      }
    },
  ]
}
