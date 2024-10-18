resource "azurerm_service_plan" "fo-app-service-plan" {
    name = "fo-asp-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name
    os_type = "Linux"
    sku_name = "B1"
    tags = var.tags
}

// Webapp UI
resource "azurerm_linux_web_app" "fo-ui-webapp" {
    name = "fo-ui-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name

    site_config {
        # Value for unconfigurable attribute
        # linux_fx_version = "DOCKER|${azurerm_container_registry.ca-acr.login_server}/${var.project}/ui:latest"
        # always_on cannot be set to true when using Free, F1, D1 Sku
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
        azurerm_service_plan.fo-app-service-plan,
        azurerm_container_registry.ca-acr,
        azurerm_subnet.fo-subnet-webapps
    ]

    service_plan_id = azurerm_service_plan.fo-app-service-plan.id
    tags = var.tags
}

// outbound level connection
resource "azurerm_app_service_virtual_network_swift_connection" "fo-ui-webapp-v-swift-connection" {
    app_service_id    = azurerm_linux_web_app.fo-ui-webapp.id
    subnet_id         = azurerm_subnet.fo-subnet-webapps.id
    depends_on = [
        azurerm_linux_web_app.fo-ui-webapp
    ]
}

// Webapp API
resource "azurerm_linux_web_app" "fo-api-webapp" {
    name = "fo-api-${var.project}-${var.enviroment}"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name

    site_config {
        # Value for unconfigurable attribute
        # linux_fx_version = "DOCKER|${azurerm_container_registry.ca-acr.login_server}/${var.project}/api:latest"
        # always_on cannot be set to true when using Free, F1, D1 Sku
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
        azurerm_service_plan.fo-app-service-plan,
        azurerm_container_registry.ca-acr,
        azurerm_subnet.fo-subnet-webapps
    ]

    service_plan_id = azurerm_service_plan.fo-app-service-plan.id
    tags = var.tags
}

// outbound level connection
resource "azurerm_app_service_virtual_network_swift_connection" "fo-api-webapp-v-swift-connection" {
    app_service_id    = azurerm_linux_web_app.fo-api-webapp.id
    subnet_id         = azurerm_subnet.fo-subnet-webapps.id
    depends_on = [
        azurerm_linux_web_app.fo-api-webapp
    ]
}