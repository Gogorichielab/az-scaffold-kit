###############################################################################
# Required inputs
###############################################################################

variable "workload" {
  description = "Short name of the workload this scaffold hosts. Used as the leading component of every generated resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.workload))
    error_message = "The workload name must be 2-12 characters of lowercase letters and digits only, because it is embedded in the globally unique storage account name."
  }
}

variable "location" {
  description = "Azure region to deploy into. Note that the Static Web App Free tier is only offered in a subset of regions."
  type        = string
}

###############################################################################
# Naming and placement
###############################################################################

variable "environment" {
  description = "Deployment environment name, used as the second component of every generated resource name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.environment))
    error_message = "The environment name must be 2-8 characters of lowercase letters and digits only."
  }
}

variable "create_resource_group" {
  description = "Whether the module creates the resource group. Set to false to deploy into a resource group that already exists."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group. When create_resource_group is true this names the group the module creates, and defaults to a generated name. When create_resource_group is false this must name an existing group."
  type        = string
  default     = null

  validation {
    condition     = var.create_resource_group || var.resource_group_name != null
    error_message = "The resource_group_name must be set when create_resource_group is false, because the module has no group to deploy into otherwise."
  }
}

variable "tags" {
  description = "Tags applied to every resource this module creates, merged over the module's own defaults."
  type        = map(string)
  default     = {}
}

###############################################################################
# Static Web App - always created
###############################################################################

variable "static_web_app_sku_tier" {
  description = "SKU tier for the Static Web App."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_tier)
    error_message = "The static_web_app_sku_tier must be either Free or Standard."
  }
}

variable "static_web_app_sku_size" {
  description = "SKU size for the Static Web App. Azure expects this to match the tier."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_size)
    error_message = "The static_web_app_sku_size must be either Free or Standard."
  }
}

###############################################################################
# Feature toggles
###############################################################################

variable "enable_function_app" {
  description = "Whether to create the Function App stack: storage account, deployment container, service plan, Log Analytics, Application Insights, and the Flex Consumption function app."
  type        = bool
  default     = false
}

variable "enable_managed_identity" {
  description = "Whether to create a user-assigned managed identity and attach it to the function app."
  type        = bool
  default     = false
}

variable "enable_failure_anomalies" {
  description = "Whether to create the Application Insights Failure Anomalies smart detector alert rule. Only has an effect when enable_function_app is true."
  type        = bool
  default     = true
}

###############################################################################
# Storage account - created when enable_function_app is true
###############################################################################

variable "storage_account_tier" {
  description = "Performance tier of the function app's storage account."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The storage_account_tier must be either Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "Replication strategy for the function app's storage account."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "The storage_account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "storage_account_kind" {
  description = "Kind of storage account to create for the function app."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "BlockBlobStorage"], var.storage_account_kind)
    error_message = "The storage_account_kind must be one of StorageV2, BlobStorage, or BlockBlobStorage."
  }
}

variable "deployment_container_name" {
  description = "Name of the blob container that holds the function app's deployment package. Flex Consumption requires a container; it has no default on the Azure side."
  type        = string
  default     = "deployments"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,62}$", var.deployment_container_name))
    error_message = "The deployment_container_name must be 3-63 characters of lowercase letters, digits, and hyphens, and must start with a letter or digit."
  }
}

###############################################################################
# Service plan - created when enable_function_app is true
###############################################################################

variable "service_plan_os_type" {
  description = "Operating system for the App Service plan. Flex Consumption is Linux only."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.service_plan_os_type)
    error_message = "The service_plan_os_type must be either Linux or Windows."
  }

  validation {
    condition     = var.service_plan_sku_name != "FC1" || var.service_plan_os_type == "Linux"
    error_message = "The service_plan_os_type must be Linux when service_plan_sku_name is FC1, because the Flex Consumption plan is offered on Linux only."
  }
}

variable "service_plan_sku_name" {
  description = "SKU for the App Service plan. FC1 selects the Flex Consumption plan, which is the only plan type this module's function app resource supports."
  type        = string
  default     = "FC1"

  validation {
    condition     = !var.enable_function_app || var.service_plan_sku_name == "FC1"
    error_message = "The service_plan_sku_name must be FC1. This module deploys azurerm_function_app_flex_consumption, which only runs on a Flex Consumption plan; other SKUs need a different function app resource."
  }
}

###############################################################################
# Function app runtime - created when enable_function_app is true
###############################################################################

variable "function_app_runtime_name" {
  description = "Language runtime for the function app."
  type        = string
  default     = "node"

  validation {
    condition     = contains(["dotnet-isolated", "java", "node", "powershell", "python"], var.function_app_runtime_name)
    error_message = "The function_app_runtime_name must be one of dotnet-isolated, java, node, powershell, or python."
  }
}

variable "function_app_runtime_version" {
  description = "Version of the language runtime, as a string. Valid values depend on function_app_runtime_name."
  type        = string
  default     = "20"
}

variable "function_app_instance_memory_in_mb" {
  description = "Memory allocated to each Flex Consumption instance."
  type        = number
  default     = 2048

  validation {
    condition     = contains([512, 2048, 4096], var.function_app_instance_memory_in_mb)
    error_message = "The function_app_instance_memory_in_mb must be one of 512, 2048, or 4096."
  }
}

variable "function_app_maximum_instance_count" {
  description = "Maximum number of instances the Flex Consumption plan will scale out to."
  type        = number
  default     = 100

  validation {
    condition     = var.function_app_maximum_instance_count >= 40 && var.function_app_maximum_instance_count <= 1000
    error_message = "The function_app_maximum_instance_count must be between 40 and 1000."
  }
}

variable "storage_authentication_type" {
  description = "How the function app authenticates to its deployment storage container. UserAssignedIdentity avoids putting an access key in state, and requires enable_managed_identity to be true."
  type        = string
  default     = "StorageAccountConnectionString"

  validation {
    condition     = contains(["StorageAccountConnectionString", "SystemAssignedIdentity", "UserAssignedIdentity"], var.storage_authentication_type)
    error_message = "The storage_authentication_type must be one of StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."
  }

  validation {
    condition     = var.storage_authentication_type != "UserAssignedIdentity" || var.enable_managed_identity
    error_message = "Set enable_managed_identity to true when storage_authentication_type is UserAssignedIdentity, because there is no identity to authenticate with otherwise."
  }
}

###############################################################################
# Monitoring - created when enable_function_app is true
###############################################################################

variable "log_analytics_workspace_id" {
  description = "ID of an existing Log Analytics workspace to back Application Insights. Leave null to have the module create one. Classic Application Insights is retired, so a workspace is always required."
  type        = string
  default     = null
}

variable "log_analytics_retention_in_days" {
  description = "Retention period for the Log Analytics workspace the module creates. Ignored when log_analytics_workspace_id is set."
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "The log_analytics_retention_in_days must be between 30 and 730."
  }
}

variable "application_insights_type" {
  description = "Application type for the Application Insights resource."
  type        = string
  default     = "web"
}

variable "action_group_ids" {
  description = "IDs of existing action groups to notify when Failure Anomalies fires. Leave empty to have the module create a minimal action group, which the alert rule API requires."
  type        = list(string)
  default     = []
}

variable "failure_anomalies_severity" {
  description = "Severity of the Failure Anomalies alert rule."
  type        = string
  default     = "Sev3"

  validation {
    condition     = contains(["Sev0", "Sev1", "Sev2", "Sev3", "Sev4"], var.failure_anomalies_severity)
    error_message = "The failure_anomalies_severity must be one of Sev0 through Sev4."
  }
}

variable "failure_anomalies_frequency" {
  description = "Evaluation frequency of the Failure Anomalies alert rule, as an ISO 8601 duration."
  type        = string
  default     = "PT1M"

  validation {
    condition     = can(regex("^PT[0-9]+[MH]$", var.failure_anomalies_frequency))
    error_message = "The failure_anomalies_frequency must be an ISO 8601 duration such as PT1M or PT15M."
  }
}
