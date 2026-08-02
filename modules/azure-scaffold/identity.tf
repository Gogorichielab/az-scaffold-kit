# Optional user-assigned identity. Kept separate from the function app so it
# survives enable_function_app being toggled off, and so callers can hand the
# same identity to other resources via the managed_identity_id output.
resource "azurerm_user_assigned_identity" "this" {
  count = var.enable_managed_identity ? 1 : 0

  name                = "id-${local.name_prefix}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = var.location

  tags = local.tags
}
