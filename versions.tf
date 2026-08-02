terraform {
  # 1.9 is the floor for referencing other variables inside a validation block,
  # which several of the input validations in variables.tf rely on.
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # azurerm_function_app_flex_consumption was introduced in v4.21.0.
      version = "~> 5.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
