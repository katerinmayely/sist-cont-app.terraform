resource "azurerm_service_plan" "fo-app-service-plan" {
    name = "fo-asp-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name
    os_type = "Linux"
    sku_name = "F1"
    tags = var.tags
}