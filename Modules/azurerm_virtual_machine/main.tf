resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                            = var.virtual_machine_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_F2"
  admin_username                  = data.azurerm_key_vault_secret.secret_username.value
  admin_password                  = data.azurerm_key_vault_secret.secret_password.value
  disable_password_authentication = "false"
  network_interface_ids           = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}