# Changelog

All notable changes to this project are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Change types used below: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

### Added

- `AGENTS.md` — guide for AI assistants working in this repo, covering Terraform
  conventions, the semantic versioning policy for the module's public interface,
  verification steps, and known Azure constraints. Directs SKU and tier choices
  to `docs/free-azure-services.md` so defaults stay on free tiers.
- `modules/azure-scaffold` — Terraform module deploying an Azure Static Web App
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
- README sections covering the Terraform module and the docs.

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

[Unreleased]: https://github.com/Gogorichielab/az-scaffold-kit/commits/main
