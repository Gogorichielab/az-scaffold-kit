# The Static Web App is the always-on baseline of the scaffold. On the Free
# tier it is available in a subset of regions only, so a deployment that fails
# here on region grounds is usually a var.location problem rather than a
# configuration one.
resource "azurerm_static_web_app" "this" {
  name                = "stapp-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location

  sku_tier = var.static_web_app_sku_tier
  sku_size = var.static_web_app_sku_size

  tags = local.tags
}
