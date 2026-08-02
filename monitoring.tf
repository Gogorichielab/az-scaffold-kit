# Classic Application Insights was retired on 29 February 2024. A workspace is
# now mandatory: creating an Application Insights resource without one lets
# Azure provision a default workspace out of band, which then shows up as a
# permanent diff on the next plan.
resource "azurerm_log_analytics_workspace" "this" {
  count = var.enable_function_app && var.log_analytics_workspace_id == null ? 1 : 0

  name                = "log-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location

  sku               = "PerGB2018"
  retention_in_days = var.log_analytics_retention_in_days

  tags = local.tags
}

resource "azurerm_application_insights" "this" {
  count = var.enable_function_app ? 1 : 0

  name                = "appi-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location

  application_type = var.application_insights_type
  workspace_id     = coalesce(var.log_analytics_workspace_id, one(azurerm_log_analytics_workspace.this[*].id))

  tags = local.tags
}

# The smart detector alert rule API rejects an empty actionGroups.groupIds, so
# the rule cannot exist without at least one action group. Callers who already
# have one pass it via var.action_group_ids and skip this.
resource "azurerm_monitor_action_group" "failure_anomalies" {
  count = var.enable_function_app && var.enable_failure_anomalies && length(var.action_group_ids) == 0 ? 1 : 0

  name                = "ag-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  short_name          = substr("ag${var.workload}", 0, 12)

  tags = local.tags
}

# Failure Anomalies has no azurerm resource, so it goes through azapi against
# the Microsoft.AlertsManagement API directly.
resource "azapi_resource" "failure_anomalies" {
  count = var.enable_function_app && var.enable_failure_anomalies ? 1 : 0

  type      = "Microsoft.AlertsManagement/smartDetectorAlertRules@2021-04-01"
  name      = "failure-anomalies-${local.name_prefix}-${local.suffix}"
  parent_id = local.resource_group_id
  location  = "global"

  body = {
    properties = {
      state       = "Enabled"
      severity    = var.failure_anomalies_severity
      frequency   = var.failure_anomalies_frequency
      description = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

      detector = {
        id = "FailureAnomaliesDetector"
      }

      scope = [azurerm_application_insights.this[0].id]

      actionGroups = {
        groupIds = length(var.action_group_ids) > 0 ? var.action_group_ids : [azurerm_monitor_action_group.failure_anomalies[0].id]
      }
    }
  }

  tags = local.tags

  # The smart detector schema is not published in the azapi schema index, so
  # provider-side validation would reject a body the API itself accepts.
  schema_validation_enabled = false
}
