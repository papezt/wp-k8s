#######################################################################################################################
# MYSQL
#######################################################################################################################

resource "random_string" "root_user_password" {
  length  = 20
  special = false
}

resource "random_string" "wp_user_password" {
  length  = 20
  special = false
}

resource "google_sql_database_instance" "wp" {
  name             = "${var.PROJECT_PREFIX}"
  database_version = "MYSQL_5_7"
  region           = "${var.GOOGLE_REGION}"

  settings {
    tier      = "db-f1-micro"
    disk_size = "10"

    location_preference {
      zone = "${var.GOOGLE_ZONE}"
    }

    ip_configuration {
      require_ssl     = false
      private_network = "projects/${var.GOOGLE_PROJECT}/global/networks/${var.DEFAULT_NETWORK}"

      authorized_networks {
        name  = "HOME"
        value = "83.240.80.243/32"
      }
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }

    maintenance_window {
      day          = "6"
      hour         = "1"
      update_track = "stable"
    }

    user_labels {
      project = "${var.PROJECT_PREFIX}"
      app     = "wp"
      stage   = "test"
    }
  }
}

resource "google_sql_database" "wp" {
  name      = "wp"
  instance  = "${google_sql_database_instance.wp.name}"
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = "${google_sql_database_instance.wp.name}"
  password = "${random_string.root_user_password.result}"
}

resource "google_sql_user" "wp" {
  name     = "wpuser"
  instance = "${google_sql_database_instance.wp.name}"
  password = "${random_string.wp_user_password.result}"
}
