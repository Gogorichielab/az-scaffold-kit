provider "azurerm" {
  features {}
}

module "resource_group" {
  source   = "../"
  name     = "az-scaffold-kit-dev-rg"
  location = "eastus"
  tags = {
    project     = "az-scaffold-kit"
    environment = "dev"
  }
}
