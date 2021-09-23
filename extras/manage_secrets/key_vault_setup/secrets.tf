resource "azurerm_key_vault_secret" "example_1" {
  name         = "adls-connect-client-secret"
  value        = "such secret"
  key_vault_id = azurerm_key_vault.self.id
}

resource "azurerm_key_vault_secret" "example_2" {
  name         = "synapse-sql-administrator-login-password"
  value        = "very key vault"
  key_vault_id = azurerm_key_vault.self.id
}
