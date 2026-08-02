# Changelog

All notable changes to this project are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Change types used below: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

### Added

- `.github/dependabot.yml` — weekly grouped dependency updates. GitHub Actions
  bumps arrive as a single pull request; Terraform provider bumps use
  `group-by: dependency-name` so one provider lands as one pull request
  updating the root module and both examples together.
- `.github/workflows/dependabot-auto-merge.yml` — auto-approves and enables
  auto-merge for GitHub Actions minor and patch bumps only. Terraform provider
  bumps are deliberately excluded, because raising a provider floor is a MAJOR
  change to this module's public interface.

## [0.1.0] - 2026-08-02

First release. The repository was renamed from `az-scaffold-kit` to
`terraform-azurerm-scaffold` and the module moved from `modules/azure-scaffold`
to the repository root, so the root is now the module consumers get.

Consume it with:

```hcl
source = "git::https://github.com/Gogorichielab/terraform-azurerm-scaffold.git?ref=v0.1.0"
```

### Added

- `AGENTS.md` — guide for AI assistants working in this repo, covering Terraform
  conventions, the semantic versioning policy for the module's public interface,
  verification steps, and known Azure constraints. Directs SKU and tier choices
  to `docs/free-azure-services.md` so defaults stay on free tiers.
- The module itself, at the repository root — deploys an Azure Static Web App
  by default, with an optional Flex Consumption Function App stack
  (`enable_function_app`) and an optional user-assigned managed identity
  (`enable_managed_identity`). Defaults to `Free`/`Free` Static Web App,
  `Standard_LRS` storage, and an `FC1` Linux plan.
- `examples/minimum` and `examples/function-app` — runnable configurations for
  the two deployment combinations, each with a `terraform.tfvars.example`.
- `.github/workflows/terraform.yml` — CI running `terraform fmt -check` and
  `terraform validate` against the module and both examples.
- `docs/free-azure-services.md` — free-tier cheat sheet covering Azure service
  allowances across 11 categories (AI & Machine Learning, Compute & Containers,
  Databases, Networking, Identity & Security, Management & Governance,
  Integration & Web, IoT & Maps, Developer Tools, Migration & Hybrid, and
  Data & Analytics).
- Change tracking for the cheat sheet: a **Last verified** date, a
  *Keeping this current* re-verification process, and a *Revision history*
  table recording changes to individual free-tier figures.
- This changelog.
- README documenting usage, inputs, outputs, and constraints.

### Notes

The module deviates from a straight reading of the original resource/SKU spec
in four places, each because the spec as written cannot deploy:

- Uses `azurerm_function_app_flex_consumption` rather than
  `azurerm_linux_function_app`, which cannot emit the `functionAppConfig`
  section an `FC1` plan requires.
- Adds a blob container for the deployment package, which Flex Consumption
  requires and which has no Azure-side default.
- Adds a Log Analytics workspace, since classic Application Insights was
  retired on 29 February 2024 and an implicit workspace causes permanent
  plan diffs.
- Adds an action group, since the `smartDetectorAlertRules` API rejects an
  empty `actionGroups.groupIds`.

`terraform plan`/`apply` against a live Azure subscription had not been run at
the time of this release. `terraform fmt`, `terraform validate`, and negative
tests of every input validation had.

[Unreleased]: https://github.com/Gogorichielab/terraform-azurerm-scaffold/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Gogorichielab/terraform-azurerm-scaffold/releases/tag/v0.1.0
