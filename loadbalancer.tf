############################################################
# IP Pública para el Load Balancer
############################################################
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "pip-lb-n8n-01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

############################################################
# Load Balancer
############################################################
resource "azurerm_lb" "n8n_lb" {
  name                = "lb-n8n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }

  tags = var.tags
}

############################################################
# Backend Pool con la VM
############################################################
resource "azurerm_lb_backend_address_pool" "n8n_backend" {
  name            = "n8n-backend-pool-01"
  loadbalancer_id = azurerm_lb.n8n_lb.id
}

# Asociar la NIC de la VM al backend pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_assoc" {
  network_interface_id    = azurerm_network_interface.ubuntu_nic.id
  ip_configuration_name   = "ipconfig01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.n8n_backend.id
}

############################################################
# Reglas de NAT Inbound para acceso HTTP/HTTPS
############################################################
resource "azurerm_lb_nat_rule" "http_nat" {
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.n8n_lb.id
  name                           = "nat-http-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicFrontend"
}

resource "azurerm_lb_nat_rule" "https_nat" {
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.n8n_lb.id
  name                           = "nat-https-443"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicFrontend"
}

# Asignar las reglas NAT a la NIC
resource "azurerm_network_interface_nat_rule_association" "nic_nat_http" {
  network_interface_id  = azurerm_network_interface.ubuntu_nic.id
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = azurerm_lb_nat_rule.http_nat.id
}

resource "azurerm_network_interface_nat_rule_association" "nic_nat_https" {
  network_interface_id  = azurerm_network_interface.ubuntu_nic.id
  ip_configuration_name = "ipconfig01"
  nat_rule_id           = azurerm_lb_nat_rule.https_nat.id
}