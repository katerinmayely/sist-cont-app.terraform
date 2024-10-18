resource "azurerm_linux_function_app" "ca-fo-function-app" {
    name                      = "fo-function-${var.project}-${var.enviroment}"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.ca-rg.name
    service_plan_id       = azurerm_service_plan.fo-app-service-plan.id
    storage_account_name      = azurerm_storage_account.ca-storage-acount.name
    storage_account_access_key = azurerm_storage_account.ca-storage-acount.primary_connection_string
    # An attribute named "version" is not expected here
    # version                   = "~3"
    # An attribute named "os_type" is not expected here
    # os_type                   = "linux"

    site_config {
        #  Can't configure a value for "site_config.0.linux_fx_version": its value will be decided automatically based on the result of applying this configuration.
        # linux_fx_version       = "DOCKER|mcr.microsoft.com/azure-functions/dotnet:4-appservice-quickstart"
        # always_on              = true
        vnet_route_all_enabled = true

        ip_restriction {
            name      = "default-deny"
            ip_address = "0.0.0.0/0"
            action    = "Deny"
            priority  = 200
        }
    }   

    app_settings = {
        "AzureWebJobsStorage"         = azurerm_storage_account.ca-storage-acount.primary_connection_string
        "AzureWebJobsDashboard"       = azurerm_storage_account.ca-storage-acount.primary_connection_string
        "WEBSITE_VNET_ROUTE_ALL"      = "1"
        "QueueStorageConnectionString" = azurerm_storage_account.ca-storage-acount.primary_connection_string
        "QueueName"                   = azurerm_storage_queue.ca-queue-answering.name
        "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.ca-acr.login_server}"
        "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.ca-acr.admin_username
        "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.ca-acr.admin_password
    }

    identity {
        type = "SystemAssigned"
    }

    tags = var.tags

    depends_on = [
        azurerm_service_plan.fo-app-service-plan,
        azurerm_subnet.fo-subnet-f-app,
        azurerm_container_registry.ca-acr
    ]
}


resource "azurerm_private_endpoint" "fo-function-private-endpoint"{

    name = "fo-function-private-endpoint-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    location = var.location
    subnet_id = azurerm_subnet.fo-subnet-f-app.id

    private_service_connection {
        name = "fo-function-private-ec-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_linux_function_app.ca-fo-function-app.id
        subresource_names = ["sites"]
        is_manual_connection = false
    }

    tags = var.tags
}

resource "azurerm_private_dns_zone" "fo-function-private-dns-zone"{
    name= "private.fo-function-${var.project}-${var.enviroment}.azurewebsites.net"
    resource_group_name = azurerm_resource_group.ca-rg.name

    tags = var.tags

}

resource "azurerm_private_dns_a_record" "fo-function-private-dns-a-record"{

    name = "function-record-${var.project}-${var.enviroment}"
    zone_name = azurerm_private_dns_zone.fo-function-private-dns-zone.name
    resource_group_name = azurerm_resource_group.ca-rg.name
    ttl = 300
    records = [azurerm_private_endpoint.fo-function-private-endpoint.private_service_connection[0].private_ip_address]

}

resource "azurerm_private_dns_zone_virtual_network_link" "vn-link-fo-function"{
    name = "fo-functionlink-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    private_dns_zone_name = azurerm_private_dns_zone.fo-function-private-dns-zone.name
    virtual_network_id = azurerm_virtual_network.ca-vn.id
}