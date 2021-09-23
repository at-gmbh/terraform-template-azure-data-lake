terraform {

  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
    azuread = {
      source  = "hashicorp/azurerm"
      version = ">= 1.5.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "David_Terraform_Backend"
    storage_account_name = "kuda42terraform"
    container_name       = "terraform-remote-state"
    key                  = "secrets.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  features {}
}

data "azurerm_resource_group" "root" {
  name = var.resource_group_name
}

data "azurerm_client_config" "self" {}
