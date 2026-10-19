terraform {
  backend "azurerm" {
    storage_account_name = "terraformsdevops"
    container_name       = "terraform"
    key                  = "infraestructura.tfstate"
  }
}