resource "azurerm_static_web_app" "this" {
  name                = var.static_web_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = var.static_web_app_sku_size
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "this" {
  count               = var.enable_user_assigned_identity ? 1 : 0
  name                = var.user_assigned_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_storage_account" "function" {
  count                    = var.enable_function_stack ? 1 : 0
  name                     = var.function_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_service_plan" "function" {
  count               = var.enable_function_stack ? 1 : 0
  name                = var.function_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.function_service_plan_sku
  tags                = var.tags
}

resource "azurerm_application_insights" "function" {
  count               = var.enable_function_stack ? 1 : 0
  name                = var.function_application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_linux_function_app" "this" {
  count               = var.enable_function_stack ? 1 : 0
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id            = azurerm_service_plan.function[0].id
  storage_account_name       = azurerm_storage_account.function[0].name
  storage_account_access_key = azurerm_storage_account.function[0].primary_access_key

  functions_extension_version = "~4"

  site_config {
    application_insights_connection_string = azurerm_application_insights.function[0].connection_string
    application_stack {
      dotnet_version = "8.0"
    }
  }

  dynamic "identity" {
    for_each = var.enable_user_assigned_identity ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this[0].id]
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "function" {
  count               = var.enable_function_stack && var.enable_alert_rule ? 1 : 0
  name                = var.function_alert_rule_name
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_function_app.this[0].id]
  description         = "Alert when Function App server errors exceed threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.function_alert_5xx_threshold
  }

  tags = var.tags
}
