###############################################################################
# Resource group
###############################################################################

output "resource_group_name" {
  description = "Name of the resource group holding the scaffold."
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group holding the scaffold."
  value       = local.resource_group_id
}

output "name_suffix" {
  description = "Random suffix applied to generated resource names. Useful for naming resources the caller creates alongside this module."
  value       = local.suffix
}

###############################################################################
# Static Web App
###############################################################################

output "static_web_app_id" {
  description = "ID of the Static Web App."
  value       = azurerm_static_web_app.this.id
}

output "static_web_app_name" {
  description = "Name of the Static Web App."
  value       = azurerm_static_web_app.this.name
}

output "static_web_app_default_host_name" {
  description = "Default hostname of the Static Web App."
  value       = azurerm_static_web_app.this.default_host_name
}

output "static_web_app_api_key" {
  description = "Deployment API key for the Static Web App."
  value       = azurerm_static_web_app.this.api_key
  sensitive   = true
}

###############################################################################
# Function app - null unless enable_function_app is true
###############################################################################

output "function_app_id" {
  description = "ID of the Flex Consumption function app, or null when enable_function_app is false."
  value       = one(azurerm_function_app_flex_consumption.this[*].id)
}

output "function_app_name" {
  description = "Name of the Flex Consumption function app, or null when enable_function_app is false."
  value       = one(azurerm_function_app_flex_consumption.this[*].name)
}

output "function_app_default_hostname" {
  description = "Default hostname of the function app, or null when enable_function_app is false."
  value       = one(azurerm_function_app_flex_consumption.this[*].default_hostname)
}

output "service_plan_id" {
  description = "ID of the App Service plan, or null when enable_function_app is false."
  value       = one(azurerm_service_plan.this[*].id)
}

###############################################################################
# Storage - null unless enable_function_app is true
###############################################################################

output "storage_account_id" {
  description = "ID of the function app's storage account, or null when enable_function_app is false."
  value       = one(azurerm_storage_account.this[*].id)
}

output "storage_account_name" {
  description = "Name of the function app's storage account, or null when enable_function_app is false."
  value       = one(azurerm_storage_account.this[*].name)
}

output "deployment_container_name" {
  description = "Name of the blob container holding the function app's deployment package, or null when enable_function_app is false."
  value       = one(azurerm_storage_container.deployments[*].name)
}

output "storage_account_primary_access_key" {
  description = "Primary access key of the function app's storage account, or null when enable_function_app is false."
  value       = one(azurerm_storage_account.this[*].primary_access_key)
  sensitive   = true
}

###############################################################################
# Monitoring - null unless enable_function_app is true
###############################################################################

output "application_insights_id" {
  description = "ID of the Application Insights resource, or null when enable_function_app is false."
  value       = one(azurerm_application_insights.this[*].id)
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace backing Application Insights. Returns the caller-supplied ID when one was passed."
  value       = var.enable_function_app ? coalesce(var.log_analytics_workspace_id, one(azurerm_log_analytics_workspace.this[*].id)) : null
}

output "action_group_ids" {
  description = "IDs of the action groups wired to the Failure Anomalies rule. Returns the caller-supplied IDs when any were passed."
  value       = length(var.action_group_ids) > 0 ? var.action_group_ids : azurerm_monitor_action_group.failure_anomalies[*].id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights, or null when enable_function_app is false."
  value       = one(azurerm_application_insights.this[*].instrumentation_key)
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights, or null when enable_function_app is false."
  value       = one(azurerm_application_insights.this[*].connection_string)
  sensitive   = true
}

###############################################################################
# Managed identity - null unless enable_managed_identity is true
###############################################################################

output "managed_identity_id" {
  description = "ID of the user-assigned managed identity, or null when enable_managed_identity is false."
  value       = one(azurerm_user_assigned_identity.this[*].id)
}

output "managed_identity_client_id" {
  description = "Client ID of the user-assigned managed identity, or null when enable_managed_identity is false."
  value       = one(azurerm_user_assigned_identity.this[*].client_id)
}

output "managed_identity_principal_id" {
  description = "Principal (object) ID of the user-assigned managed identity, for use in role assignments. Null when enable_managed_identity is false."
  value       = one(azurerm_user_assigned_identity.this[*].principal_id)
}
