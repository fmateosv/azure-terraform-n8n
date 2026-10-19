############################################################
# Network Interface (NIC) sin IP pública
############################################################
resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "nic-ubuntu-n8n01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_fco_host.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

############################################################
# Virtual Machine Ubuntu 22.04 LTS GEN2
############################################################
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                            = "vm-ubuntu-n8n01"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  availability_set_id             = azurerm_availability_set.n8n_asg.id

  network_interface_ids = [
    azurerm_network_interface.ubuntu_nic.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 127
  }

  tags = var.tags
}