# azure-scaffold

Stands up the Azure side of a live-coding project: a Static Web App you always get, and a Flex Consumption Function App stack you opt into. Defaults sit on free and consumption tiers so an idle scaffold costs nothing.

## Usage

Pin `?ref=` to a release tag so the module cannot change under you between applies.

```hcl
module "scaffold" {
  source = "git::https://github.com/Gogorichielab/az-scaffold-kit.git//modules/azure-scaffold?ref=v0.1.0"

  workload    = "myapp"
  environment = "dev"
  location    = "eastus2"
}
```

Adding the Function App stack and a managed identity:

```hcl
module "scaffold" {
  source = "git::https://github.com/Gogorichielab/az-scaffold-kit.git//modules/azure-scaffold?ref=v0.1.0"

  workload    = "myapp"
  environment = "dev"
  location    = "eastus2"

  enable_function_app     = true
  enable_managed_identity = true
}
```

Tags version the whole repository, docs included, so a doc-only release still bumps the tag. What `?ref=` guarantees is that the module's behaviour is fixed, not that every tag changed it.

Working examples: [`examples/minimum`](../../examples/minimum), [`examples/function-app`](../../examples/function-app).

## What gets created

| Azure resource | Terraform resource | Created when | Default SKU / configuration |
| --- | --- | --- | --- |
| Resource Group | `azurerm_resource_group.this` | `create_resource_group` | — |
| Static Web App | `azurerm_static_web_app.this` | Always | Tier `Free`, size `Free` |
| Storage Account | `azurerm_storage_account.this` | `enable_function_app` | `Standard`, `LRS`, `StorageV2` |
| Storage Container | `azurerm_storage_container.deployments` | `enable_function_app` | Private; holds the deployment package |
| App Service Plan | `azurerm_service_plan.this` | `enable_function_app` | SKU `FC1`, OS `Linux` |
| Log Analytics Workspace | `azurerm_log_analytics_workspace.this` | `enable_function_app` and no `log_analytics_workspace_id` | `PerGB2018`, 30-day retention |
| Application Insights | `azurerm_application_insights.this` | `enable_function_app` | Type `web`; workspace-based |
| Function App | `azurerm_function_app_flex_consumption.this` | `enable_function_app` | Runs on the FC1 plan; no separate SKU |
| Action Group | `azurerm_monitor_action_group.failure_anomalies` | `enable_function_app` and no `action_group_ids` | No SKU |
| Failure Anomalies | `azapi_resource.failure_anomalies` | `enable_function_app && enable_failure_anomalies` | Severity `Sev3`, frequency `PT1M` |
| Managed Identity | `azurerm_user_assigned_identity.this` | `enable_managed_identity` | No SKU |

### Deployment combinations

**Minimum** — Resource Group, Static Web App (`Free`/`Free`).

**Function-enabled** — the above plus Storage Account (`Standard_LRS`), deployment container, Linux App Service Plan (`FC1`), Function App, Log Analytics, Application Insights, Action Group, Failure Anomalies.

**Optional addition** — user-assigned managed identity.

## Required inputs

| Name | Type | Description |
| --- | --- | --- |
| `workload` | `string` | Short workload name, 2–12 lowercase alphanumerics. Leads every generated resource name. |
| `location` | `string` | Azure region. Must support the Static Web App Free tier, and the Flex Consumption plan when the function app is enabled. |

## Optional inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `environment` | `string` | `"dev"` | Second component of every generated name, 2–8 lowercase alphanumerics. |
| `create_resource_group` | `bool` | `true` | Create the resource group, or deploy into an existing one. |
| `resource_group_name` | `string` | `null` | Names the created group, or selects the existing one. Required when `create_resource_group` is `false`. |
| `tags` | `map(string)` | `{}` | Merged over the module's own tags and applied to every resource. |
| `static_web_app_sku_tier` | `string` | `"Free"` | `Free` or `Standard`. |
| `static_web_app_sku_size` | `string` | `"Free"` | `Free` or `Standard`. |
| `enable_function_app` | `bool` | `false` | Create the Function App stack. |
| `enable_managed_identity` | `bool` | `false` | Create a user-assigned identity and attach it to the function app. |
| `enable_failure_anomalies` | `bool` | `true` | Create the Failure Anomalies rule. Only applies when the function app is enabled. |
| `storage_account_tier` | `string` | `"Standard"` | `Standard` or `Premium`. |
| `storage_account_replication_type` | `string` | `"LRS"` | `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, or `RAGZRS`. |
| `storage_account_kind` | `string` | `"StorageV2"` | `StorageV2`, `BlobStorage`, or `BlockBlobStorage`. |
| `deployment_container_name` | `string` | `"deployments"` | Blob container holding the deployment package. |
| `service_plan_os_type` | `string` | `"Linux"` | Must be `Linux` when the SKU is `FC1`. |
| `service_plan_sku_name` | `string` | `"FC1"` | Must be `FC1` while `enable_function_app` is true — see [Constraints](#constraints). |
| `function_app_runtime_name` | `string` | `"node"` | `dotnet-isolated`, `java`, `node`, `powershell`, or `python`. |
| `function_app_runtime_version` | `string` | `"20"` | Valid values depend on the runtime. |
| `function_app_instance_memory_in_mb` | `number` | `2048` | `512`, `2048`, or `4096`. |
| `function_app_maximum_instance_count` | `number` | `100` | Between 40 and 1000. |
| `storage_authentication_type` | `string` | `"StorageAccountConnectionString"` | `StorageAccountConnectionString`, `SystemAssignedIdentity`, or `UserAssignedIdentity`. |
| `log_analytics_workspace_id` | `string` | `null` | Reuse an existing workspace instead of creating one. |
| `log_analytics_retention_in_days` | `number` | `30` | Between 30 and 730. |
| `application_insights_type` | `string` | `"web"` | Application Insights application type. |
| `action_group_ids` | `list(string)` | `[]` | Existing action groups for the alert rule. Empty means the module creates one. |
| `failure_anomalies_severity` | `string` | `"Sev3"` | `Sev0` through `Sev4`. |
| `failure_anomalies_frequency` | `string` | `"PT1M"` | ISO 8601 duration. |

## Outputs

Resource group: `resource_group_name`, `resource_group_id`, `name_suffix`.

Static Web App: `static_web_app_id`, `static_web_app_name`, `static_web_app_default_host_name`, `static_web_app_api_key` (sensitive).

Function app: `function_app_id`, `function_app_name`, `function_app_default_hostname`, `service_plan_id`.

Storage: `storage_account_id`, `storage_account_name`, `deployment_container_name`, `storage_account_primary_access_key` (sensitive).

Monitoring: `application_insights_id`, `log_analytics_workspace_id`, `action_group_ids`, `application_insights_instrumentation_key` (sensitive), `application_insights_connection_string` (sensitive).

Managed identity: `managed_identity_id`, `managed_identity_client_id`, `managed_identity_principal_id`.

Everything gated behind a toggle returns `null` when that toggle is off, so callers can reference outputs unconditionally.

## Constraints

**`FC1` is the only supported plan SKU.** The module deploys `azurerm_function_app_flex_consumption`, which runs on Flex Consumption and nothing else. A `service_plan_sku_name` other than `FC1` fails at plan time with an explicit message rather than an opaque API error about a missing `functionAppConfig` section. Hosting on Consumption, Premium, or Dedicated needs `azurerm_linux_function_app` instead — a different module.

**Flex Consumption is Linux only,** so `service_plan_os_type` must stay `Linux` while the SKU is `FC1`.

**Application Insights is always workspace-based.** Classic Application Insights was retired on 29 February 2024. Creating the resource without a workspace lets Azure provision one out of band, which then shows up as a permanent diff. Pass `log_analytics_workspace_id` to reuse a workspace, or let the module create one.

**The Failure Anomalies rule needs an action group.** The `smartDetectorAlertRules` API rejects an empty `actionGroups.groupIds`, so the module creates a minimal action group unless you pass `action_group_ids`. The group has no receivers — add them yourself, or pass a group that already has them.

**Regions are limited.** The Static Web App Free tier and the Flex Consumption plan are each offered in a subset of regions, and `location` has to satisfy both when the function app is enabled.

**No role assignments.** The managed identity is created with no roles, because the module cannot know what your functions need. Use `managed_identity_principal_id` to grant them.

## Providers

| Provider | Version | Why |
| --- | --- | --- |
| `hashicorp/azurerm` | `~> 4.21` | `azurerm_function_app_flex_consumption` was added in 4.21.0. |
| `Azure/azapi` | `~> 2.0` | Failure Anomalies has no `azurerm` resource. |
| `hashicorp/random` | `~> 3.6` | Storage account names are globally unique; a random suffix keeps the module reusable. |

Terraform `>= 1.9.0`, which is the floor for validation rules that reference other variables.

Note that those cross-variable validations are evaluated at **plan** time, not by `terraform validate`. A `terraform validate` pass does not prove the inputs are consistent — run `terraform plan`.
