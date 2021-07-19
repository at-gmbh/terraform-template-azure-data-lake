resource "azurerm_synapse_workspace" "self" {
  name                                 = "synapse-${local.environment}"
  resource_group_name                  = azurerm_resource_group.root.name
  location                             = azurerm_resource_group.root.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "tbd"
}

resource "azurerm_synapse_sql_pool" "self" {
  name                 = "main-sql-pool"
  synapse_workspace_id = azurerm_synapse_workspace.self.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}

resource "azurerm_synapse_firewall_rule" "azure_services" {
  # Allow all Azure connections
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.self.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

resource "azurerm_synapse_firewall_rule" "enable_all_ips" {
  # Allow all ips to connect to db
  name                 = "AllowAllIps"
  synapse_workspace_id = azurerm_synapse_workspace.self.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
