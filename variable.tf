############################################################
# Variables globales
############################################################
variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se despliega"
  type        = string
  default     = "rg-espana-dev-001"
}
 
variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "spaincentral"
}
 
############################################################
# Variables de red
############################################################
variable "vnet_name" {
  description = "Nombre de la red virtual"
  type        = string
  default     = "vnet-fco-01"
}
 
variable "vnet_address_space" {
  description = "Espacio de direcciones de la VNet"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}
 
variable "subnet_name" {
  description = "Nombre de la subred"
  type        = string
  default     = "subnet-fco-host-01"
}
 
variable "subnet_prefix" {
  description = "Prefijo de la subred"
  type        = string
  default     = "10.0.0.0/27"
}
 
############################################################
# Variables de máquina virtual
############################################################
variable "admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}
 
variable "admin_password" {
  description = "Contraseña del administrador de la VM (inyectada desde secret GitHub Actions)"
  type        = string
  sensitive   = true
  nullable    = false
}
 
############################################################
# Imagen de la máquina virtual
############################################################

variable "vm_image_publisher" {
  description = "Publisher de la imagen"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "Offer de la imagen"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  description = "SKU de la imagen"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  description = "Versión de la imagen"
  type        = string
  default     = "latest"
}


 
############################################################
# Tags globales
############################################################
variable "tags" {
  description = "Etiquetas comunes para los recursos"
  type        = map(string)
  default = {
    environment = "Dev"
    owner       = "Francisco Mateos"
    costcenter  = "finops"
  }
}