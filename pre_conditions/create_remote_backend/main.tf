terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tf_backend" {
  name = "David_Terraform_Backend"
  location = "Switzerland North"
}

resource "azurerm_storage_account" "remote_state" {
  name = "kuda42terraform"
  resource_group_name = azurerm_resource_group.tf_backend.name
  location = azurerm_resource_group.tf_backend.location
  account_tier = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "remote_state" {
  name = "terraform-remote-state"
  storage_account_name = azurerm_storage_account.remote_state.name
}
