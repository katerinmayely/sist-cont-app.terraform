// Database server
resource "azurerm_mssql_server" "ca-mssql-server" {
    name = "mssql-server-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    location = var.location
    version = "12.0"
    administrator_login = var.sql-user
    administrator_login_password = var.sql-password
    tags = var.tags
}

// Cont App database for front-office
resource "azurerm_mssql_database" "ca-fo-mssql-database" {
    name = "fo.${var.project}.db"
    server_id = azurerm_mssql_server.ca-mssql-server.id
    sku_name = "S0"
    tags = var.tags
}

// Cont App database for back-office
resource "azurerm_mssql_database" "ca-bo-mssql-database" {
    name = "bo.${var.project}.db"
    server_id = azurerm_mssql_server.ca-mssql-server.id
    sku_name = "S0"
    tags = var.tags
}

// Private endpoint for database service
resource "azurerm_private_endpoint" "ca-mssql-server-pe" {
    name = "ca-mssql-server-${var.project}-${var.enviroment}-pe"
    resource_group_name = azurerm_resource_group.ca-rg.name
    location = var.location
    subnet_id = azurerm_subnet.subnet-db.id
    private_service_connection {
        name = "mssql-private-sc-${var.project}-${var.enviroment}"
        is_manual_connection = false
        private_connection_resource_id = azurerm_mssql_server.ca-mssql-server.id
        subresource_names = ["sqlServer"]
    }
    tags = var.tags
}

// DNS Zone Configuration
resource "azurerm_private_dns_zone" "db-p-dns-zone" {
    name = "private.db.mssql_server.link.database"
    resource_group_name = azurerm_resource_group.ca-rg.name
    tags = var.tags
}

// DNS Record - Database service through private endpoint
resource "azurerm_private_dns_a_record" "mssqlserver-dns-record" {
    name = "mssqlserver-dns-record-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    zone_name = azurerm_private_dns_zone.db-p-dns-zone.name
    ttl = 300
    records = [ azurerm_private_endpoint.ca-mssql-server-pe.private_service_connection[0].private_ip_address ]
}

// Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "vn_link_db" {
    name = "vn-link-db-${var.project}-${var.enviroment}"
    resource_group_name = azurerm_resource_group.ca-rg.name
    private_dns_zone_name = azurerm_private_dns_zone.db-p-dns-zone.name
    virtual_network_id = azurerm_virtual_network.ca-vn.id
}