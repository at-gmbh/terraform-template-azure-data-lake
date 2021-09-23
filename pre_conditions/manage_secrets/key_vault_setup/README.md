# Manage Your Secrets in Azure Key Vault

If you plan on using secrets such as passwords you could use the [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/). You can create the secrets with a separate state file. That way you do not need to take care of managing secrets in the main terraform files inside `/src/`. That way you never need to worry about checking in secrets to version control, for instance. Instead, you can call every secret with a "terraform data object".

Let's make an example. Let's say that you have a password that you need to share with all the engineers. You first create a secret in Azure Key Vault. After that, you can use that secret in Terraform with the following object. That way you never need to hardcode the secret in your code. Neither will you ever need to manage environment variables. You can simply call all secrets from the Azure Key Vault. 

```hcl
# Once you have created the key vault from the outside of this code, you can
# Access all the secrets from within this code. 

# First, you call the Azure Key Vault resource.
data "azurerm_key_vault" "self" {
  name                = "key-vault-${var.env_tag}"
  resource_group_name = data.azurerm_resource_group.root.name
}

# Then, you call individual secrets from that key vault.
data "azurerm_key_vault_secret" "adls_connect_client_secret" {
  name         = "adls-connect-client-secret"
  key_vault_id = data.azurerm_key_vault.self.id
}
```
