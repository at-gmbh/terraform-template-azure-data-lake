# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create a storage account for receiving data from suppliers.

resource "azurerm_storage_account" "landing" {
  # External suppliers may use this storage account to upload files:
  name                     = "kuda42${local.environment}"
  location                 = azurerm_resource_group.root.location
  resource_group_name      = azurerm_resource_group.root.name
  account_tier             = "Standard"
  access_tier              = "Hot"
  is_hns_enabled           = true
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  allow_blob_public_access = false
}

resource "azurerm_storage_data_lake_gen2_filesystem" "landing" {
  name               = "objects"
  storage_account_id = azurerm_storage_account.landing.id

  # Set ACL for the Service Principal "ADLS Connect"
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.adls_connect.id
    permissions = "rwx"
  }

  # Set ACL for the group "Alexander Thamm Engineers"
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.at_engineers.id
    permissions = "rwx"
  }
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create a storage account (ADLS Gen2) for the ETL with Databricks / Spark.

resource "azurerm_storage_account" "adls" {
  # Main storage account for the data lake:
  name                     = "kuda42lake${local.environment}"
  location                 = azurerm_resource_group.root.location
  resource_group_name      = azurerm_resource_group.root.name
  account_tier             = "Standard"
  access_tier              = "Hot"
  is_hns_enabled           = true
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  allow_blob_public_access = false
}

resource "azurerm_storage_data_lake_gen2_filesystem" "root" {
  name               = "root"
  storage_account_id = azurerm_storage_account.adls.id

  # Set ACL for the Service Principal "ADLS Connect"
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.adls_connect.id
    permissions = "rwx"
  }

  # Set ACL for the group "Alexander Thamm Engineers"
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.at_engineers.id
    permissions = "rwx"
  }
}

resource "azurerm_storage_data_lake_gen2_path" "etl_directories" {
  for_each           = toset(["1-landing", "2-raw", "3-clean", "4-core", "5-serve"])
  path               = each.key
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.root.name
  storage_account_id = azurerm_storage_account.adls.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "databricks_config" {
  # Config files that should be available in databricks should be stored in this directory.
  path               = "databricks_config"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.root.name
  storage_account_id = azurerm_storage_account.adls.id
  resource           = "directory"
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create a file system for Synapse

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse" {
  # Synapse requires it's own file system.
  name               = "synapse-filesystem"
  storage_account_id = azurerm_storage_account.adls.id

  # Set ACL for the Service Principal "ADLS Connect"
  ace {
    scope       = "access"
    type        = "user"
    id          = azuread_service_principal.adls_connect.id
    permissions = "rwx"
  }

  # Set ACL for the group "Alexander Thamm Engineers"
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.at_engineers.id
    permissions = "rwx"
  }
}
