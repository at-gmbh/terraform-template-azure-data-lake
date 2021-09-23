# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Setup Terraform and providers
terraform {

  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }
    databricks = {
      source  = "databrickslabs/databricks"
      version = ">= 0.3.6"
    }
  }

  backend "azurerm" {
    # As defined in ../pre_conditions/create_remote_backend/main.tf
    resource_group_name  = "Terraform_Backend"
    storage_account_name = "uniquelowercasename42"
    container_name       = "terraform-remote-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  # In case you do not have full permissions uncomment the next line:
  # skip_provider_registration = true
}

provider "azuread" {
  # In case you do not have full permissions uncomment the next line:
  # skip_provider_registration = true
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create the root Resource Group
resource "azurerm_resource_group" "root" {
  name     = "Data_Lake_Distributed_ETL"
  location = "Switzerland North"
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Get client config
data "azurerm_client_config" "self" {}
