resource "azurerm_app_service_plan" "bo-app-service-plan" {
    name = "bo-asp-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name
    kind                = "Linux"
    reserved            = true
    tags = var.tags

    sku {
    tier = "Standard"
    size = "B1"
  }
}

// Webapp UI
resource "azurerm_app_service" "bo-ui-webapp" {
    name = "bo-ui-${var.project}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name

    site_config {
        # linux_fx_version = "DOCKER|${azurerm_container_registry.ca-acr.login_server}/${var.project}/ui:latest"
        always_on = false
        vnet_route_all_enabled = true
    }

    # app_settings = {
    #     "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.ca-acr.login_server}"
    #     "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.ca-acr.admin_username
    #     "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.ca-acr.admin_password
    #     "WEBSITE_VNET_ROUTE_ALL"          = "1"
    # }

    depends_on = [
        azurerm_app_service_plan.bo-app-service-plan,
        azurerm_container_registry.ca-acr,
        azurerm_subnet.bo-subnet-webapps
    ]

    app_service_plan_id = azurerm_app_service_plan.bo-app-service-plan.id
    tags = var.tags
}

// outbound level connection
resource "azurerm_app_service_virtual_network_swift_connection" "bo-ui-webapp-v-swift-connection" {
    app_service_id    = azurerm_app_service.bo-ui-webapp.id
    subnet_id         = azurerm_subnet.bo-subnet-webapps.id
    depends_on = [
        azurerm_app_service.bo-ui-webapp
    ]
}

// Webapp API
resource "azurerm_app_service" "bo-api-webapp" {
    name = "bo-api-${var.project}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name

    site_config {
        # linux_fx_version = "DOCKER|${azurerm_container_registry.ca-acr.login_server}/${var.project}/api:latest"
        always_on = false
        vnet_route_all_enabled = true
    }

    app_settings = {
        "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.ca-acr.login_server}"
        "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.ca-acr.admin_username
        "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.ca-acr.admin_password
        "WEBSITE_VNET_ROUTE_ALL"          = "1"
    }

    depends_on = [
        azurerm_app_service_plan.bo-app-service-plan,
        azurerm_container_registry.ca-acr,
        azurerm_subnet.bo-subnet-webapps
    ]

    app_service_plan_id = azurerm_app_service_plan.bo-app-service-plan.id
    tags = var.tags
}

// outbound level connection
resource "azurerm_app_service_virtual_network_swift_connection" "bo-api-webapp-v-swift-connection" {
    app_service_id    = azurerm_app_service.bo-api-webapp.id
    subnet_id         = azurerm_subnet.bo-subnet-webapps.id
    depends_on = [
        azurerm_app_service.bo-api-webapp
    ]
}