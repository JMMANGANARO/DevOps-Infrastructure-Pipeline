# modules/database/main.tf
# Purpose: Creates Azure SQL Database infrastructure for 3-tier architecture

# Random password generation for SQL Server admin
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Store SQL Server admin password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Azure SQL Server (logical server)
resource "azurerm_mssql_server" "main" {
  name                         = "sql-${var.environment}-${var.suffix}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result

  # Security configurations
  minimum_tls_version               = "1.2"
  public_network_access_enabled     = false  # Private access only
  outbound_network_restriction_enabled = false

  # Azure Active Directory authentication
  azuread_administrator {
    login_username = "sqladmin@yourdomain.com"  # Replace with your admin
    object_id      = data.azurerm_client_config.current.object_id
  }

  tags = var.tags
}

# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "sqldb-${var.environment}-app"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 32
  sku_name       = var.database_sku
  zone_redundant = false

  # Backup and recovery settings
  short_term_retention_policy {
    retention_days = 7
  }

  long_term_retention_policy {
    weekly_retention  = "P1W"
    monthly_retention = "P1M"
    yearly_retention  = "P1Y"
    week_of_year     = 1
  }

  tags = var.tags
}

# Private endpoint for SQL Server (secure network access)
resource "azurerm_private_endpoint" "sql_server" {
  name                = "pe-sql-${var.environment}-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-sql-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# SQL Server firewall rule for Azure services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

