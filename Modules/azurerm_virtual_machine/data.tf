data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
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