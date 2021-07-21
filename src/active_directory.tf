# Manage your Azure Active Directory settings here. 

# These resources / settings are mainly used to either set ACL on 
# the storage account or make role assignments.

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create the service principal "ADLS Connect"
# This service principal is used to connect Azure resources to the data lake.
# For example you can use this service principal to connect Azure Databricks
# to the ADLS.

resource "azuread_application" "adls_connect" {
  # This security principal is used to connect Resources to the storage account.
  # Example: Connect databricks to storage account.
  display_name               = "ADLS Connect by Terraform"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_application_password" "adls_connect" {
  # Create a client secret for ADLS Connect
  application_object_id = azuread_application.adls_connect.object_id
}

resource "azuread_service_principal" "adls_connect" {
  # Use this resource to refer to the service principal
  application_id               = azuread_application.adls_connect.application_id
  app_role_assignment_required = false
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Create the service principal "ADLS Load"
# This service principal is used to enable external suppliers to upload
# data to the ADLS. Assign the role "Data Contributor" to this service principal
# on the level of the storage account or the file system.

resource "azuread_application" "adls_load" {
  # This security principal is used to connect Resources to the storage account.
  # Example: Connect databricks to storage account.
  display_name               = "ADLS Load by Terraform"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_application_password" "adls_load" {
  # Create a client secret for ADLS Connect
  application_object_id = azuread_application.adls_load.object_id
}

resource "azuread_service_principal" "adls_load" {
  # Use this resource to refer to the service principal
  application_id               = azuread_application.adls_load.application_id
  app_role_assignment_required = false
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Call users and assign to a group

data "azuread_users" "users" {
  user_principal_names = [
    "asad@mathiasthammalexanderthamm.onmicrosoft.com",
    "dku@mathiasthammalexanderthamm.onmicrosoft.com"
  ]
}

resource "azuread_group" "at_engineers" {
  display_name = "AT Engineers"
  members = toset([for s in data.azuread_users.users.object_ids : s])
}