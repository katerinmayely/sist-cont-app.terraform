provider "azurerm" {
    features {}
    subscription_id = "9bb06f1b-62f9-4bd2-827d-357c44794a6c"
}

resource "azurerm_resource_group" "ca-rg" {
    name = "rg-${var.project}-${var.enviroment}"
    location = var.location
    tags = var.tags
}