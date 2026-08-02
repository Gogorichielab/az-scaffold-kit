output "resource_group_name" {
  description = "Name of the resource group the scaffold created."
  value       = module.scaffold.resource_group_name
}

output "static_web_app_name" {
  description = "Name of the Static Web App."
  value       = module.scaffold.static_web_app_name
}

output "static_web_app_default_host_name" {
  description = "Public hostname of the Static Web App."
  value       = module.scaffold.static_web_app_default_host_name
}
