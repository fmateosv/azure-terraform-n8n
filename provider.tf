terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Conexión a tu suscripción
  subscription_id = "aafe7cdf-ec4b-4062-b952-985b47394bd5"
  tenant_id       = "f9082694-5379-4912-bbe1-1c5e9b6737d7"

  # (opcional, solo si usas un Service Principal)
  client_id     = "723451f1-9252-4349-823f-3501983dc879"
  client_secret = "qNc8Q~FzeLSiNncWPHYvQ7Qe2qMTNP8EWoVsTa4s"
}