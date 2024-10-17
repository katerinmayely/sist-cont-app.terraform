provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "ca-rg" {
    name = "rg-${var.project}-${var.enviroment}"
    location = var.location
    tags = var.tags
}