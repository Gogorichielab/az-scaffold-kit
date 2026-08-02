terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

# The source address is the one an external caller would use. Pin ?ref= to a
# release tag so the module cannot change under you between applies.
module "scaffold" {
  source = "git::https://github.com/Gogorichielab/terraform-azurerm-scaffold.git?ref=v0.1.0"

  workload    = var.workload
  environment = var.environment
  location    = var.location

  enable_function_app     = true
  enable_managed_identity = true

  function_app_runtime_name    = var.function_app_runtime_name
  function_app_runtime_version = var.function_app_runtime_version

  tags = {
    "cost-center" = "demo"
  }
}
