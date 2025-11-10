terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "ravi1"
    storage_account_name = "devopravi111125"
    container_name       = "tfstate"
    key                  = "devaks.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "f3a6f2dc-eb0a-4db2-bed3-644813c52712"
}
