# Starter Agent Guidance

Use this guide when kicking off a new live-coding Azure project in this repository.

## Kickoff checklist
- Confirm project name and short service description.
- Choose target environment (`dev` first).
- Confirm region and expected cost constraints.
- Identify required Azure services and whether free-tier options exist.

## Recommended first tasks for an AI coding agent
1. Scaffold or update Terraform modules in `infra/terraform/modules`.
2. Wire modules from `infra/terraform/environments/dev`.
3. Add/update variables, outputs, and module README notes where needed.
4. Run `terraform fmt -recursive`, `terraform validate`, and `terraform plan`.
5. Summarize planned resources and estimated cost impact.

## Guardrails
- Do not hardcode secrets or credentials.
- Keep naming consistent with `AGENTS.md`.
- Keep module interfaces simple and explicit.
- Prefer reusable modules over one-off inline resources.
