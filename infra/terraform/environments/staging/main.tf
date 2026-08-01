terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for staging."
}

variable "project_name" {
  type        = string
  default     = "azscaffold"
  description = "Project prefix used for resource naming."
}

variable "enable_function_stack" {
  type        = bool
  default     = false
  description = "Enable optional Function App stack resources."
}

variable "enable_user_assigned_identity" {
  type        = bool
  default     = false
  description = "Enable optional user-assigned managed identity."
}

locals {
  env           = "staging"
  resource_base = lower("${var.project_name}-${local.env}")
  tags = {
    project     = var.project_name
    environment = local.env
    managed_by  = "terraform"
  }
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "${local.resource_base}-rg"
  location = var.location
  tags     = local.tags
}

module "web_app" {
  source = "../../modules/web-app"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  static_web_app_name     = "${local.resource_base}-swa"
  static_web_app_sku_tier = "Free"
  static_web_app_sku_size = "Free"

  enable_function_stack              = var.enable_function_stack
  function_storage_account_name      = var.enable_function_stack ? replace(substr("${local.resource_base}funcsa", 0, 24), "-", "") : null
  function_service_plan_name         = var.enable_function_stack ? "${local.resource_base}-func-plan" : null
  function_application_insights_name = var.enable_function_stack ? "${local.resource_base}-appi" : null
  function_app_name                  = var.enable_function_stack ? "${local.resource_base}-func" : null
  function_alert_rule_name           = var.enable_function_stack ? "${local.resource_base}-func-5xx-alert" : null

  enable_user_assigned_identity = var.enable_user_assigned_identity
  user_assigned_identity_name   = var.enable_user_assigned_identity ? "${local.resource_base}-uami" : null

  tags = local.tags
}
