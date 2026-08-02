variable "workload" {
  description = "Short name of the workload this scaffold hosts."
  type        = string
  default     = "scaffold"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region to deploy into. Must support both the Static Web App Free tier and the Flex Consumption plan."
  type        = string
  default     = "eastus2"
}

variable "function_app_runtime_name" {
  description = "Language runtime for the function app."
  type        = string
  default     = "node"
}

variable "function_app_runtime_version" {
  description = "Version of the language runtime, as a string."
  type        = string
  default     = "20"
}
