resource "azurerm_key_vault" "self" {
  name                       = "advbi-key-vault-${var.env_tag}"
  location                   = data.azurerm_resource_group.root.location
  resource_group_name        = data.azurerm_resource_group.root.name
  tenant_id                  = data.azurerm_client_config.self.tenant_id
  sku_name                   = "standard"
}

resource "azurerm_key_vault_access_policy" "at_engineers" {
  key_vault_id = azurerm_key_vault.self.id
  tenant_id    = data.azurerm_client_config.self.tenant_id
  object_id    = data.azuread_group.at_engineers.object_id

  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "List",
    "Update"
  ]

  secret_permissions = [
    "Get",
    "Delete",
    "List",
    "Set",
    "Purge",
    "Backup",
    "Recover",
    "Restore"
  ]
}
