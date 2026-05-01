terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "goose-cross-cloud-rg"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique lowercase Azure storage account name"
  default     = "goosecrossclouddemo"
}

variable "container_name" {
  type    = string
  default = "goose-objects"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "object_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    project     = "goose-cross-cloud"
    environment = "demo"
    provider    = "azure"
  }
}

resource "azurerm_storage_container" "objects" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.object_storage.id
  container_access_type = "private"
}
