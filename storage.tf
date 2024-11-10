resource "azurerm_storage_account" "ca-storage-acount" {
    name = "mystoragesistcontappdev"
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = var.tags
}

// Blob container for user files
resource "azurerm_storage_container" "ca-files-container" {
    name = "blobfiles"
    storage_account_id = azurerm_storage_account.ca-storage-acount.id
    container_access_type = "private"
}


// Blob container for invoices 
resource "azurerm_storage_container" "ca-invoices" {
    name = "blobinvoinces"
    storage_account_id = azurerm_storage_account.ca-storage-acount.id
    container_access_type = "private"
}

// Queue for answering requests
resource "azurerm_storage_queue" "ca-queue-answering" {
    name = "queue-storage-requests"
    storage_account_name = azurerm_storage_account.ca-storage-acount.name
}

// Private endpoints for connect with dns zone
resource "azurerm_private_endpoint" "blob_private_endpoint" {
    name = "blob-pe-${var.project}-${var.enviroment}"
    location = var.location
    subnet_id = azurerm_subnet.subnet_storage.id
    resource_group_name = azurerm_resource_group.ca-rg.name
    private_service_connection {
        name = "psc-blob-storage-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_storage_account.ca-storage-acount.id
        subresource_names = ["blob"]
        is_manual_connection = false
    }
    tags = var.tags
}

resource "azurerm_private_endpoint" "queue_private_endpoint" {
    name = "queue-pe-${var.project}-${var.enviroment}"
    private_service_connection {
        name = "psc-queue-storage-${var.project}-${var.enviroment}"
        private_connection_resource_id = azurerm_storage_account.ca-storage-acount.id
        is_manual_connection = false
        subresource_names = ["queue"]
    }
    subnet_id = azurerm_subnet.subnet_storage.id
    location = var.location
    resource_group_name = azurerm_resource_group.ca-rg.name
}

// DNS Zone
resource "azurerm_private_dns_zone" "my-storage-p-dns-zone" {
    name = "myprivate.storage_account.link.storage"
    resource_group_name = azurerm_resource_group.ca-rg.name
    tags = var.tags
}

// Records
resource "azurerm_private_dns_a_record" "name" {
    name = "storage-record-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    ttl = 300
    zone_name = azurerm_private_dns_zone.fo-function-private-dns-zone.name
    records = [ azurerm_private_endpoint.blob_private_endpoint.private_service_connection[0].private_ip_address,
                azurerm_private_endpoint.queue_private_endpoint.private_service_connection[0].private_ip_address ]
}

// DNS Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "vn-link-storage" {
    name = "my.vn-link-storage-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    virtual_network_id = azurerm_virtual_network.ca-vn.id
    private_dns_zone_name = azurerm_private_dns_zone.my-storage-p-dns-zone.name
}