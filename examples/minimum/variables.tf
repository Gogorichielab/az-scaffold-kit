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
  description = "Azure region to deploy into. The Static Web App Free tier is only offered in a subset of regions."
  type        = string
  default     = "eastus2"
}
