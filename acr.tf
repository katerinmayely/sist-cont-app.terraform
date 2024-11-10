resource "azurerm_container_registry" "ca-acr" {
    name = "myacrsistcontapp"
    resource_group_name = azurerm_resource_group.ca-rg.name
    location = var.location
    sku = "Basic"
    admin_enabled = true
    tags = var.tags
}