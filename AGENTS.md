# AGENTS.md

Instructions for AI coding agents working in this repository. Humans may find it useful too, but it is written for agents.

## What this repo is

`az-scaffold-kit` stands up the Azure side of a live-coding project fast and cheap. It holds a reusable Terraform module, runnable examples, and reference docs. It is optimised for *starting* projects, so **defaults must stay on free or consumption tiers** — an idle scaffold should cost nothing.

```
modules/azure-scaffold/   the module (reusable, consumed by other repos)
examples/                 runnable root modules, one per deployment combination
docs/                     reference documentation
.github/workflows/        CI
```

## Cost and SKU decisions

**Consult [`docs/free-azure-services.md`](docs/free-azure-services.md) before choosing or changing any SKU, tier, or size.** It records what each Azure service gives away for free.

Rules:

- New resources default to their free tier when one exists. If none exists, default to the cheapest consumption option and say so in the module README's cost notes.
- Never raise a default SKU for performance without being asked. Add an input instead and leave the default alone.
- Check the **Last verified** date at the top of that document. If it is more than a quarter old, treat its figures as unconfirmed and verify against the [Azure free services page](https://azure.microsoft.com/pricing/free-services/) before relying on them.
- When you learn a free-tier allowance has changed, update that document *and* its Revision history table, per its own [Keeping this current](docs/free-azure-services.md#keeping-this-current) section.
- Free-tier figures describe the always-free tier on pay-as-you-go. The 12-month introductory offers are deliberately out of scope — do not mix them in.

## Terraform conventions

Follow the [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure) and HashiCorp's [module creation pattern](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation).

**Structure**

- `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf` always exist, even when thin. Split resource creation into topic files (`function_app.tf`, `monitoring.tf`) once `main.tf` stops being scannable.
- **Never put a `provider` block in a module.** Modules declare `required_providers` only; examples configure providers.
- Every externally usable module needs a `README.md`, or Terraform tooling treats it as internal.

**Inputs**

- Name variables in full. `enable_function_app`, not `func`.
- Every variable gets a `description`, a `type`, and a `validation` block wherever Azure constrains the value.
- Required inputs have no default. Optional inputs have a default that is correct for most callers.
- Write error messages that say what to do, not just what is wrong.

**Resources**

- Conditional resources use `count = var.enable_x ? 1 : 0` on the whole resource. Do not scatter conditional expressions through resource arguments.
- Outputs for conditional resources use `one(resource.name[*].attr)` so they return `null` rather than erroring when the toggle is off.
- Mark every secret-bearing output `sensitive = true`.
- Apply the merged `local.tags` to every taggable resource.

**Lock files**

Provider lock files belong to root modules. `modules/**/.terraform.lock.hcl` is gitignored, because pinning providers inside a consumed module misleads — the consuming root module's lock file is the one that applies.

## Verifying changes

Run these before committing any `.tf` change. CI runs the same checks.

```bash
terraform fmt -check -recursive

cd modules/azure-scaffold && terraform init -backend=false && terraform validate
```

To validate an example, rewrite its module source to the local checkout first — examples point at the public git address on purpose, so validating them as-is would test the published tag instead of your working copy. `.github/workflows/terraform.yml` shows the exact `sed`.

**`terraform validate` is not sufficient.** Validation rules that reference *other* variables are evaluated at **plan** time, not by `validate`. A green `validate` proves syntax and provider schema only — it does not prove that a combination of inputs is accepted. To exercise those rules without a subscription, run `terraform plan` with dummy `ARM_*` credentials: variable validation runs before provider authentication, so the validation error surfaces ahead of the auth failure.

Test validations **negatively**. A validation nobody has seen reject anything is not known to work.

`terraform plan`/`apply` against a real subscription needs credentials that CI does not have. Never claim a module is deploy-verified on the strength of `validate` alone — say plainly what was and was not run.

## Versioning and releases

This repo follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html). Releases are git tags of the form `vMAJOR.MINOR.PATCH`, and consumers pin them:

```hcl
source = "git::https://github.com/Gogorichielab/az-scaffold-kit.git//modules/azure-scaffold?ref=v0.1.0"
```

The module's **public interface** is its input variables, its outputs, and the infrastructure a given set of inputs produces. Version against that interface, not against the size of the diff.

| Bump | When |
| --- | --- |
| **MAJOR** | Removing or renaming an input or output. Adding a required input. Changing a default such that an unchanged config deploys different infrastructure. Any change that forces replacement of an existing resource. Raising the Terraform or provider floor. |
| **MINOR** | Adding an optional input whose default preserves current behaviour. Adding an output. Adding a resource behind a toggle that defaults off. |
| **PATCH** | Bug fixes that move behaviour toward what was documented. Documentation, comments, and error-message wording that does not change what is accepted or rejected. |

While the module is `0.x`, MINOR carries breaking changes and MAJOR stays at `0` — a `0.x` tag is not a stability promise. Once the input surface settles, tag `v1.0.0` and the table above applies strictly.

Every release gets a `CHANGELOG.md` entry under its version heading, in [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Add entries under `Unreleased` as you work; do not wait for release time.

Tags cover the whole repository, docs included, so a docs-only release still moves the tag. That is expected: `?ref=` guarantees the module's behaviour is fixed, not that every tag changed it.

## Working agreements

- Match the surrounding style. Comments in this repo explain *why*, not *what* — a comment restating the resource type is noise.
- Update `CHANGELOG.md` in the same commit as the change it describes.
- When a spec you were handed cannot work, say so and explain why before building an alternative. Record the deviation in `CHANGELOG.md` and the PR body. Do not silently "fix" a spec.
- Report honestly what you verified. If a check was skipped or failed, say which and why.

## Known constraints

Things that have already cost time here. Check these before debugging from scratch.

- **`FC1` is the only supported plan SKU** in `azure-scaffold`. It deploys `azurerm_function_app_flex_consumption`, which runs on Flex Consumption and nothing else. `azurerm_linux_function_app` cannot emit the `functionAppConfig` section an FC1 plan requires — the pairing fails at apply. Other plan types need a different function app resource.
- **Flex Consumption is Linux only.**
- **Application Insights must be workspace-based.** Classic was retired 29 February 2024. Omitting `workspace_id` lets Azure provision a workspace out of band, which then shows up as a permanent plan diff.
- **The Failure Anomalies rule requires an action group.** `smartDetectorAlertRules` rejects an empty `actionGroups.groupIds`.
- **Storage account names are globally unique,** 3–24 characters, lowercase alphanumerics only. That is why the module appends a `random_string` suffix rather than deriving names from `workload` and `environment` alone.
- **Region availability is narrow.** The Static Web App Free tier and the Flex Consumption plan are each offered in a subset of regions, and `location` must satisfy both when the function app is enabled.
- **The module assigns the managed identity no roles.** It cannot know what your functions need. Callers grant roles using the `managed_identity_principal_id` output.
