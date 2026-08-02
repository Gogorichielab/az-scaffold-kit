# az-scaffold-kit
Live-code Azure apps fast. Terraform modules, an Agents dot M D guide for AI assistants, a free-tier services cheat sheet, and ready-to-use skills to scaffold your idea and shape it on the fly. Fun, fast, and built for building in public.

## Terraform module

[`modules/azure-scaffold`](modules/azure-scaffold) stands up the Azure side of a project: a Static Web App you always get, and a Flex Consumption Function App stack you opt into. Defaults sit on free and consumption tiers, so an idle scaffold costs nothing.

```hcl
module "scaffold" {
  source = "git::https://github.com/Gogorichielab/az-scaffold-kit.git//modules/azure-scaffold?ref=v0.1.0"

  workload    = "myapp"
  environment = "dev"
  location    = "eastus2"

  enable_function_app     = true   # storage, plan, function app, monitoring
  enable_managed_identity = true   # optional user-assigned identity
}
```

Pin `?ref=` to a release tag. Full inputs, outputs, and constraints are in the [module README](modules/azure-scaffold/README.md); runnable configurations are in [`examples/`](examples).

## Docs

- [AGENTS.md](AGENTS.md) — conventions for AI assistants working in this repo: Terraform practices, semantic versioning rules, verification steps, and known constraints.
- [Free Azure Services](docs/free-azure-services.md) — free-tier cheat sheet of what each Azure service gives you at no cost.
- [Changelog](CHANGELOG.md) — notable changes to this project.

Azure changes its free-tier allowances without notice, so the cheat sheet carries a **Last verified** date and a revision history. Check that date before trusting a figure, and follow [Keeping this current](docs/free-azure-services.md#keeping-this-current) when re-verifying.
