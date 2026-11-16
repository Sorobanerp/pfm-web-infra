terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  type    = string
  default = "pfm-platform-prod"
}

variable "environment" {
  type    = string
  default = "prod"
}

resource "google_service_account" "pfm_web_sa" {
  project      = var.project_id
  account_id   = "pfm-web-nextjs-${var.environment}"
  display_name = "PFM Web Next.js Service Account"
}
