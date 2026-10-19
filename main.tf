###########################################################
# Backend remoto y provider
############################################################
terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

############################################################
# Resource Group existente
############################################################
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
