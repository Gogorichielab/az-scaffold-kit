# AGENTS.md

This repository is a live-coding Azure starter kit scaffolded for Terraform-first infrastructure provisioning.

## Repository conventions
- Keep production code and infra code separate:
  - `infra/terraform/modules/*` contains reusable Terraform modules.
  - `infra/terraform/environments/*` composes modules for each environment.
  - `docs/*` contains reference guides.
  - `skills/snippets/*` contains reusable prompts/snippets for fast scaffolding.
- Prefer small, focused pull requests.
- Never commit secrets (`*.tfvars`, credentials, tokens).

## Naming standards
- Terraform module directories: lowercase kebab-case (for example: `web-app`).
- Terraform resource names: `<project>-<env>-<service>` where possible.
- Environment directories: `dev`, `staging`, `prod`.
- Variables and outputs: snake_case.

## Terraform module wiring model
1. Environment root (for example `infra/terraform/environments/dev`) owns provider configuration, remote state, and environment-specific variable values.
2. Environment root calls modules in this order:
   - `resource-group`
   - `network`
   - `app-service-plan`
   - `web-app`
3. Each module exports required outputs consumed by downstream modules:
   - `resource-group` outputs resource group name and location.
   - `network` consumes RG outputs and exports subnet IDs.
   - `app-service-plan` consumes RG outputs and exports plan ID.
   - `web-app` consumes RG outputs, plan ID, and subnet IDs.
4. Keep module interfaces explicit: update `variables.tf` and `outputs.tf` together when changing contracts.

## Provisioning workflow for AI coding agents
1. Start in one environment folder (usually `infra/terraform/environments/dev`).
2. Run `terraform init`.
3. Run `terraform fmt -recursive` from `infra/terraform`.
4. Run `terraform validate`.
5. Run `terraform plan` and review for unexpected drift.
6. Only apply after human approval.
