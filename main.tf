# Random suffix keeps generated names unique. The storage account name in
# particular has to be globally unique across all of Azure, so the module
# cannot derive names from workload and environment alone.
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 1 : 0

  name     = coalesce(var.resource_group_name, "rg-${local.name_prefix}-${local.suffix}")
  location = var.location
  tags     = local.tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1

  name = var.resource_group_name
}

locals {
  suffix      = random_string.suffix.result
  name_prefix = "${var.workload}-${var.environment}"

  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
  resource_group_id   = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id

  # Storage account names allow only lowercase alphanumerics and cap at 24
  # characters, so this strips separators rather than reusing name_prefix.
  storage_account_name = substr(
    lower(replace("st${var.workload}${var.environment}${local.suffix}", "/[^a-zA-Z0-9]/", "")),
    0,
    24,
  )

  tags = merge(
    {
      "managed-by"  = "terraform"
      "module"      = "azure-scaffold"
      "workload"    = var.workload
      "environment" = var.environment
    },
    var.tags,
  )
}
