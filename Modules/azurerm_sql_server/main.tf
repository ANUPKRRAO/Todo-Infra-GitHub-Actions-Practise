resource "azurerm_mssql_server" "example" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.secret_username.value
  administrator_login_password = data.azurerm_key_vault_secret.secret_password.value
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "secret_username" {
  name         = var.secret_username_name
  key_vault_id = data.azurerm_key_vault.kv.id
}
data "azurerm_key_vault_secret" "secret_password" {
  name         = var.secret_password_name
  key_vault_id = data.azurerm_key_vault.kv.id
}