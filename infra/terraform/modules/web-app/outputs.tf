output "static_web_app_id" {
  description = "Static Web App ID."
  value       = azurerm_static_web_app.this.id
}

output "function_app_id" {
  description = "Function App ID when function stack is enabled."
  value       = try(azurerm_linux_function_app.this[0].id, null)
}

output "user_assigned_identity_id" {
  description = "User-assigned managed identity ID when enabled."
  value       = try(azurerm_user_assigned_identity.this[0].id, null)
}
