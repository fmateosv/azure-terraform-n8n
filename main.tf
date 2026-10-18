############################################################
# Resource Group existente
############################################################
data "azurerm_resource_group" "rg" {
  name = "rg-espana-dev-001"
}

############################################################
# Variables generales
############################################################
variable "location"            { default = "westeurope" }
variable "resource_group_name" { default = "rg-espana-dev-001" }
variable "vnet_name"           { default = "vnet-fco" }
variable "subnet_name"         { default = "subnet-fco-host" }
variable "vnet_address_space"  { default = ["10.0.0.0/24"] }
variable "subnet_prefix"       { default = "10.0.0.0/28" }
variable "admin_username"      { default = "azureuser" }
variable "admin_password"      { default = "M1cr0s0ft123!" }
variable "tags" {
  default = {
    environment = "dev"
    owner       = "Francisco Mateos"
  }
}

############################################################
# Virtual Network
############################################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

############################################################
# Subred
############################################################
resource "azurerm_subnet" "subnet_fco_host" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

############################################################
# Network Security Group (NSG)
############################################################
resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "nsg-ubuntu-n8n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow SSH from anywhere"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP from anywhere"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS from anywhere"
  }

  tags = var.tags
}

############################################################
# Asociar NSG a la Subred
############################################################
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet_fco_host.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

############################################################
# Availability Set (ASG) para n8n
############################################################
resource "azurerm_availability_set" "n8n_asg" {
  name                        = "as-n8n"
  location                    = var.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true

  tags = var.tags
}

############################################################
# IP Pública (Static + Standard)
############################################################
resource "azurerm_public_ip" "ubuntu_pip" {
  name                = "pip-ubuntu-n8n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

############################################################
# Network Interface (NIC)
############################################################
resource "azurerm_network_interface" "ubuntu_nic" {
  name                = "nic-ubuntu-n8n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_fco_host.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_pip.id
  }

  tags = var.tags
}

############################################################
# Virtual Machine Ubuntu 22.04 LTS GEN2
############################################################
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                            = "vm-ubuntu-n8n"
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

