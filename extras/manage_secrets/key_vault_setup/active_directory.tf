data "azuread_group" "at_engineers" {
  display_name     = "AT Engineers"
  security_enabled = true
}
