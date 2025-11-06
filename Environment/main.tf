module "azurerm_resource_group" {
  source                  = "../Modules/azurerm_resource_group"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "azurerm_virtual_network" {
  depends_on           = [module.azurerm_resource_group]
  source               = "../Modules/azurerm_virtual_network"
  virtual_network_name = var.virtual_network_name
  address_space        = ["10.0.0.0/16"]
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
}

module "azurerm_frontend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../Modules/azurerm_subnet"
  subnet_name          = var.frontend_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}

module "azurerm_backend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../Modules/azurerm_subnet"
  subnet_name          = var.backend_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
}

module "frontend_public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../Modules/azurerm_public_ip"
  pip_name            = var.frontend_pip_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

module "backend_public_ip" {
  depends_on          = [module.azurerm_virtual_network]
  source              = "../Modules/azurerm_public_ip"
  pip_name            = var.backend_pip_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}

module "frontend_vm" {
  depends_on = [
    module.azurerm_frontend_subnet,
    module.frontend_public_ip,
    module.key_vault,
    module.vm_password_secret,
    module.vm_username_secret
  ]
  source                 = "../Modules/azurerm_virtual_machine"
  network_interface_name = var.frontend_nic_name
  location               = var.resource_group_location
  resource_group_name    = var.resource_group_name
  ip_name                = var.frontend_ip_name
  virtual_machine_name   = var.frontend_vm_name
  subnet_name            = var.frontend_subnet_name
  virtual_network_name   = var.virtual_network_name
  public_ip_name         = var.frontend_pip_name
  secret_username_name   = var.vm_username_secret_name
  secret_password_name   = var.vm_password_secret_name
  image_publisher        = "Canonical"
  image_offer            = "ubuntu-24_04-lts"
  image_sku              = "ubuntu-pro-gen1"
  image_version          = "latest"
  key_vault_name         = var.key_vault_name
}

module "backend_vm" {
  depends_on = [
    module.azurerm_backend_subnet,
    module.backend_public_ip,
    module.key_vault,
    module.vm_password_secret,
    module.vm_username_secret
  ]
  source                 = "../Modules/azurerm_virtual_machine"
  network_interface_name = var.backend_nic_name
  location               = var.resource_group_location
  resource_group_name    = var.resource_group_name
  ip_name                = var.backend_ip_name
  virtual_machine_name   = var.backend_vm_name
  subnet_name            = var.backend_subnet_name
  virtual_network_name   = var.virtual_network_name
  public_ip_name         = var.backend_pip_name
  secret_username_name   = var.vm_username_secret_name
  secret_password_name   = var.vm_password_secret_name
  image_publisher        = "Canonical"
  image_offer            = "0001-com-ubuntu-server-focal"
  image_sku              = "20_04-lts"
  image_version          = "latest"
  key_vault_name         = var.key_vault_name
}

module "sql_server" {
  depends_on = [
    module.azurerm_resource_group,
    module.key_vault,
    module.vm_username_secret,
    module.vm_password_secret
  ]
  source               = "../Modules/azurerm_sql_server"
  sql_server_name      = var.sql_server_name
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  key_vault_name       = var.key_vault_name
  secret_username_name = var.vm_username_secret_name
  secret_password_name = var.vm_password_secret_name
}

module "sql_database" {
  depends_on          = [module.sql_server]
  source              = "../Modules/azurerm_sql_database"
  database_name       = var.sql_database_name
  sql_server_name     = var.sql_server_name
  resource_group_name = var.resource_group_name
}

module "key_vault" {
  depends_on          = [module.azurerm_resource_group]
  source              = "../Modules/azurerm_key_vault"
  key_vault_name      = var.key_vault_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

module "vm_username_secret" {
  depends_on          = [module.key_vault]
  source              = "../Modules/azurerm_key_vault_secret"
  key_vault_name      = var.key_vault_name
  secret_name         = var.vm_username_secret_name
  secret_value        = "anupkrrao"
  resource_group_name = var.resource_group_name
}

module "vm_password_secret" {
  depends_on          = [module.key_vault, module.vm_username_secret]
  source              = "../Modules/azurerm_key_vault_secret"
  key_vault_name      = var.key_vault_name
  secret_name         = var.vm_password_secret_name
  secret_value        = "Anup@Secure2025"
  resource_group_name = var.resource_group_name
}