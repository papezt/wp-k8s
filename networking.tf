resource "google_compute_address" "wp" {
  name   = "wp-ip"
  region = "${var.GOOGLE_REGION}"
}
