provider "databricks" {
  azure_resource_group = azurerm_resource_group.root.name
  azure_tenant_id      = data.azurerm_client_config.self.tenant_id
  azure_workspace_name = azurerm_databricks_workspace.self.name
}

resource "azurerm_databricks_workspace" "self" {
  name                = "databricks-workspace-${local.environment}"
  resource_group_name = azurerm_resource_group.root.name
  location            = azurerm_resource_group.root.location
  sku                 = "premium"
}

data "databricks_spark_version" "self" {
  depends_on = [azurerm_databricks_workspace.self]
}

data "databricks_node_type" "self" {
  depends_on = [azurerm_databricks_workspace.self]
}

resource "databricks_cluster" "fixed" {
  cluster_name            = "Fixed Cluster"
  idempotency_token       = "terraform_fixed"
  spark_version           = var.spark_version
  driver_node_type_id     = var.driver_node_type_id
  node_type_id            = var.node_type_id
  num_workers             = 1
  autotermination_minutes = 60
}

resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Shared Autoscaling"
  idempotency_token       = "terraform_scaled"
  spark_version           = data.databricks_spark_version.self.id
  node_type_id            = data.databricks_node_type.self.id
  autotermination_minutes = 60
  autoscale {
    min_workers = 1
    max_workers = 50
  }
}

resource "databricks_secret_scope" "self" {
    name                     = "adls"
    initial_manage_principal = "users"
}

resource "databricks_secret" "adls_connect_client_secret" {
  scope        = databricks_secret_scope.self.name
  key          = "adls_connect_client_secret"
  string_value = azuread_application_password.adls_connect.value
}

resource "databricks_secret" "adls_connect_client_id" {
  scope        = databricks_secret_scope.self.name
  key          = "adls_connect_client_id"
  string_value = azuread_service_principal.adls_connect.application_id
}

resource "databricks_secret" "tenant_id" {
  scope        = databricks_secret_scope.self.name
  key          = "tenant_id"
  string_value = data.azurerm_client_config.self.tenant_id
}

resource "databricks_token" "data_factory" {
  comment = "Use this token for Azure Data Factory"
}