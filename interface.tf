variable "GOOGLE_PROJECT" {
  description = "Google Cloud Platform project id"
}

variable "GOOGLE_REGION" {
  description = "Google Cloud Platform default region"
  default     = "europe-west1"
}

variable "GOOGLE_ZONE" {
  description = "Google Cloud Platform default zone"
  default     = "europe-west1-d"
}

variable "GOOGLE_ZONE_SECONDARY" {
  description = "Google Cloud Platform secondary backup zone"
  default     = "europe-west1-c"
}

variable "DEFAULT_NETWORK" {
  description = "Google Cloud DEFAULT network name"
  default     = "default"
}

variable "PROJECT_PREFIX" {
  description = "Base name for all resources"
  default     = "wordpress-testing"
}
