output "resource_group_name" {
  description = "Name of the resource group the scaffold created."
  value       = module.scaffold.resource_group_name
}

output "static_web_app_default_host_name" {
  description = "Public hostname of the Static Web App."
  value       = module.scaffold.static_web_app_default_host_name
}

output "function_app_name" {
  description = "Name of the Flex Consumption function app."
  value       = module.scaffold.function_app_name
}

output "function_app_default_hostname" {
  description = "Public hostname of the function app."
  value       = module.scaffold.function_app_default_hostname
}

output "storage_account_name" {
  description = "Name of the function app's storage account."
  value       = module.scaffold.storage_account_name
}

output "managed_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity, for granting it roles on other resources."
  value       = module.scaffold.managed_identity_principal_id
}
