resource "azurerm_data_factory" "self" {
  name                = "kuda42-data-factory-${local.environment}"
  resource_group_name = azurerm_resource_group.root.name
  location            = azurerm_resource_group.root.location
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "self" {
  name                = "linked_service_adls"
  resource_group_name = azurerm_resource_group.root.name
  data_factory_name   = azurerm_data_factory.self.name
  connection_string   = azurerm_storage_account.adls.primary_connection_string
}

resource "azurerm_data_factory_linked_service_azure_databricks" "self" {
  name                = "linked_service_databricks"
  data_factory_name   = azurerm_data_factory.self.name
  resource_group_name = azurerm_resource_group.root.name
  description         = "Azure Databricks Linked Service via Access Token"
  existing_cluster_id = databricks_cluster.fixed.id

  access_token = databricks_token.data_factory.token_value
  adb_domain   = "https://${azurerm_databricks_workspace.self.workspace_url}"
}
