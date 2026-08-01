# terraform-azurerm-resource_group

Terraform module for provisioning an Azure Resource Group.

## Module structure
- `main.tf` - core resource definitions
- `variables.tf` - module input variables
- `outputs.tf` - module outputs
- `versions.tf` - Terraform and provider version constraints
- `examples/basic` - best-practice runnable module example
- `ExampleConfiguration` - compatibility sample path

## Usage
```hcl
module "resource_group" {
  source   = "./terraform-azurerm-resource_group"
  name     = "az-scaffold-kit-dev-rg"
  location = "eastus"

  tags = {
    project     = "az-scaffold-kit"
    environment = "dev"
  }
}
```

## Requirements
| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 3.0 |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Resource group name | `string` | n/a | yes |
| location | Resource group location | `string` | n/a | yes |
| tags | Optional resource tags | `map(string)` | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| id | Resource group ID |
| resource_group_name | Resource group name |
| location | Resource group location |
