resource "azurerm_storage_account" "this" {
  count = var.enable_function_app ? 1 : 0

  name                = local.storage_account_name
  resource_group_name = local.resource_group_name
  location            = var.location

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  tags = local.tags
}

# Flex Consumption reads its deployment package from a blob container. Both
# storage_container_type and storage_container_endpoint are required on the
# function app, so this container is not optional.
resource "azurerm_storage_container" "deployments" {
  count = var.enable_function_app ? 1 : 0

  name                  = var.deployment_container_name
  storage_account_id    = azurerm_storage_account.this[0].id
  container_access_type = "private"
}

resource "azurerm_service_plan" "this" {
  count = var.enable_function_app ? 1 : 0

  name                = "asp-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location

  os_type  = var.service_plan_os_type
  sku_name = var.service_plan_sku_name

  tags = local.tags
}

resource "azurerm_function_app_flex_consumption" "this" {
  count = var.enable_function_app ? 1 : 0

  name                = "func-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this[0].id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.this[0].primary_blob_endpoint}${azurerm_storage_container.deployments[0].name}"
  storage_authentication_type = var.storage_authentication_type

  # Exactly one of these applies, depending on storage_authentication_type.
  storage_access_key                = var.storage_authentication_type == "StorageAccountConnectionString" ? azurerm_storage_account.this[0].primary_access_key : null
  storage_user_assigned_identity_id = var.storage_authentication_type == "UserAssignedIdentity" ? azurerm_user_assigned_identity.this[0].id : null

  runtime_name    = var.function_app_runtime_name
  runtime_version = var.function_app_runtime_version

  instance_memory_in_mb  = var.function_app_instance_memory_in_mb
  maximum_instance_count = var.function_app_maximum_instance_count

  site_config {
    application_insights_connection_string = azurerm_application_insights.this[0].connection_string
    application_insights_key               = azurerm_application_insights.this[0].instrumentation_key
  }

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this[0].id]
    }
  }

  tags = local.tags
}
