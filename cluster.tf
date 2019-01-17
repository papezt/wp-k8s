resource "google_container_cluster" "cluster" {
  name    = "${var.PROJECT_PREFIX}"
  zone    = "${var.GOOGLE_ZONE}"
  network = "projects/${var.GOOGLE_PROJECT}/global/networks/${var.DEFAULT_NETWORK}"

  min_master_version = "1.10.9-gke.5"

  initial_node_count       = 1
  remove_default_node_pool = true

  ip_allocation_policy {
    subnetwork_name = "wp-subnetwork"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }
}

resource "google_container_node_pool" "default_pool" {
  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["node_count"]
  }

  name    = "default-pool"
  zone    = "${var.GOOGLE_ZONE}"
  cluster = "${google_container_cluster.cluster.name}"

  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair = true
  }

  node_config {
    machine_type = "g1-small"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]

    // labels
    labels = {
      "project"      = "${google_container_cluster.cluster.project}"
      "cluster_name" = "${google_container_cluster.cluster.name}"
      "pool_name"    = "default_pool"
    }
  }
}

resource "kubernetes_namespace" "wp" {
  metadata {
    labels {
      service = "wp"
    }

    name = "wp"
  }
}

resource "kubernetes_secret" "wp" {
  metadata {
    name      = "wp-secret"
    namespace = "wp"
  }

  data {
    DB_USER = "${google_sql_user.wp.name}"
    DB_PASS = "${google_sql_user.wp.password}"
    DB_CONN = "${google_sql_database_instance.wp.ip_address.1.ip_address}"
  }
}
