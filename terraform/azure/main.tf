terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "resource_group_name" {
  type    = string
  default = "rg-pfm-web-nextjs"
}

variable "location" {
  type    = string
  default = "brazilsouth"
}

resource "azurerm_user_assigned_identity" "pfm_web_identity" {
  name                = "id-pfm-web-nextjs-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
}
