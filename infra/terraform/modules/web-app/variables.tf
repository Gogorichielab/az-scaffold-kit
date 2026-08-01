variable "resource_group_name" {
  description = "Resource group for all resources in this module."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module."
  type        = string
}

variable "static_web_app_name" {
  description = "Name of the Static Web App."
  type        = string
}

variable "static_web_app_sku_tier" {
  description = "SKU tier for the Static Web App."
  type        = string
  default     = "Free"
}

variable "static_web_app_sku_size" {
  description = "SKU size for the Static Web App."
  type        = string
  default     = "Free"
}

variable "enable_function_stack" {
  description = "When true, deploy function app stack (storage, plan, insights, function app, alert)."
  type        = bool
  default     = false
}

variable "function_storage_account_name" {
  description = "Storage account name for the Function App (required when function stack is enabled)."
  type        = string
  default     = null
}

variable "function_service_plan_name" {
  description = "Service plan name for the Function App stack (required when function stack is enabled)."
  type        = string
  default     = null
}

variable "function_service_plan_sku" {
  description = "SKU name for the Function App service plan."
  type        = string
  default     = "Y1"
}

variable "function_application_insights_name" {
  description = "Application Insights name for the Function App stack (required when function stack is enabled)."
  type        = string
  default     = null
}

variable "function_app_name" {
  description = "Function App name (required when function stack is enabled)."
  type        = string
  default     = null
}

variable "enable_alert_rule" {
  description = "When true and function stack is enabled, deploy a Function App metric alert rule."
  type        = bool
  default     = true
}

variable "function_alert_rule_name" {
  description = "Alert rule name for Function App server errors (required when function stack + alert enabled)."
  type        = string
  default     = null
}

variable "function_alert_5xx_threshold" {
  description = "Threshold for Http5xx alert."
  type        = number
  default     = 1
}

variable "enable_user_assigned_identity" {
  description = "When true, deploy a user-assigned managed identity."
  type        = bool
  default     = false
}

variable "user_assigned_identity_name" {
  description = "User-assigned managed identity name (required when identity is enabled)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Optional tags applied to resources."
  type        = map(string)
  default     = {}
}
