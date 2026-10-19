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
# Máquina virtual 
############################################################
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = "vm-ubuntu-n8n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_B1s"

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.ubuntu_nic.id
  ]

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 127
  }

  tags = var.tags
}