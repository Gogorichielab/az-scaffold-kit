terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
  }
}

provider "azurerm" {
  features {}
}

# The source address is the one an external caller would use. Pin ?ref= to a
# release tag so the module cannot change under you between applies.
module "scaffold" {
  source = "git::https://github.com/Gogorichielab/az-scaffold-kit.git//modules/azure-scaffold?ref=v0.1.0"

  workload    = var.workload
  environment = var.environment
  location    = var.location

  tags = {
    "cost-center" = "demo"
  }
}
