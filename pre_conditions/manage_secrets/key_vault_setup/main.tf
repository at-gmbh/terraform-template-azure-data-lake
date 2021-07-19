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
    resource_group_name  = "BIDEVELOP"
    storage_account_name = "advtfbackenddev"
    container_name       = "terraform-remote-state"
    key                  = "secrets.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "azuread" {
  features {}
  skip_provider_registration = true
}

module "key_vault_setup" {
  source              = "..\/modules\/key_vault_setup"
  resource_group_name = "BIDEVELOP"
  env_tag             = "dev"
}