# modules/database/outputs.tf
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "private_endpoint_ip" {
  description = "Private IP address of the SQL Server"
  value       = azurerm_private_endpoint.sql_server.private_service_connection[0].private_ip_address
}

output "connection_string" {
  description = "Connection string template for applications"
  value       = "Server=${azurerm_mssql_server.main.fully_qualified_domain_name};Database=${azurerm_mssql_database.main.name};User Id=${var.admin_username};Password={password_from_keyvault};Encrypt=true;TrustServerCertificate=false;"
  sensitive   = true
}