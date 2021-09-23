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
  name = "Terraform_Backend"
  location = "Switzerland North"
}

resource "azurerm_storage_account" "remote_state" {
  # https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-endpoints
  # "Storage account names must be between 3 and 24 characters in length and
  # may contain numbers and lowercase letters only."
  # "Your storage account name must be unique within Azure. No two storage 
  # accounts can have the same name."
  name = "uniquelowercasename42"
  resource_group_name = azurerm_resource_group.tf_backend.name
  location = azurerm_resource_group.tf_backend.location
  account_tier = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "remote_state" {
  name = "terraform-remote-state"
  storage_account_name = azurerm_storage_account.remote_state.name
}
