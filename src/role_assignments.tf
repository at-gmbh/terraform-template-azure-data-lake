resource "azurerm_role_assignment" "adls_load" {
  scope                = azurerm_storage_account.landing.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.adls_load.id
}

resource "azurerm_role_assignment" "adls_connect" {
  scope                = azurerm_databricks_workspace.self.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.adls_connect.id
}
