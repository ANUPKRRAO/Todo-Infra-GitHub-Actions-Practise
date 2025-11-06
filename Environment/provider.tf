terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.46.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e32d395e-fd1a-4356-aad1-204b91db1cb4"
}