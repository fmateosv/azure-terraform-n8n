############################################################
# Network Security Group (NSG)
############################################################
resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "nsg-ubuntu-n8n-01"
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
# Asociación NSG <-> Subred
############################################################
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet_fco_host.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}
############################################################
# Availability Set (ASG) para n8n
############################################################
resource "azurerm_availability_set" "n8n_asg" {
  name                        = "as-n8n-01"
  location                    = var.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true

  tags = var.tags
}