terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
  default     = "replace-me"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique GCS bucket name"
  default     = "goose-cross-cloud-gcp-demo"
}

resource "google_storage_bucket" "object_storage" {
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true

  labels = {
    project     = "goose-cross-cloud"
    environment = "demo"
    provider    = "gcp"
  }
}
