# Terraform Starter Snippet

Use this reusable snippet to quickly scaffold a new environment module composition:

```hcl
module "resource_group" {
  source   = "../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}
```

Adapt inputs/outputs to the module contracts defined in `infra/terraform/modules`.
