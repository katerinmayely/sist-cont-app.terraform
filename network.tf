// Virtual network
resource "azurerm_virtual_network" "ca-vn" {
    name = "vnet-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    location = var.location
    address_space = [ "10.0.0.0/16" ]
    tags = var.tags
}

// Database server subnet
resource "azurerm_subnet" "subnet-db" {
    name = "subnet-db-${var.project}-${var.enviroment}"
    virtual_network_name = azurerm_virtual_network.ca-vn.name
    address_prefixes = [ "10.0.1.0/24" ]
    resource_group_name = azurerm_resource_group.ca-rg.name
}

// Storage subnet
resource "azurerm_subnet" "subnet_storage" {
    name = "subnet-storage-${var.project}-${var.enviroment}"
    virtual_network_name = azurerm_virtual_network.ca-vn.name
    address_prefixes = [ "10.0.2.0/24" ]
    resource_group_name = azurerm_resource_group.ca-rg.name
}

// Webapps subnet
resource "azurerm_subnet" "subnet-webapps" {
    name = "subnet-webapps-${var.project}-${var.enviroment}"
    virtual_network_name = azurerm_virtual_network.ca-vn.name
    address_prefixes = [ "10.0.3.0/24" ]
    resource_group_name = azurerm_resource_group.ca-rg.name
}

// Function app subnet
resource "azurerm_subnet" "subnet-f-app" {
    name = "subnet-f-app-${var.project}-${var.enviroment}"
    virtual_network_name = azurerm_virtual_network.ca-vn.name
    address_prefixes = [ "10.0.4.0/24" ]
    resource_group_name = azurerm_resource_group.ca-rg.name
}