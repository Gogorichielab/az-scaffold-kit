terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

variable "name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Resource group location"
  type        = string
}

variable "tags" {
  description = "Optional resource tags"
  type        = map(string)
  default     = {}
}

output "id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}
