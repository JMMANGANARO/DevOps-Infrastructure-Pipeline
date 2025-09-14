# terraform/outputs.tf
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "web_vm_name" {
  description = "Name of the web tier VM"
  value       = module.compute.web_vm_name
}

output "app_vm_name" {
  description = "Name of the app tier VM"
  value       = module.compute.app_vm_name
}

output "web_vm_public_ip" {
  description = "Public IP of the web VM"
  value       = module.compute.web_vm_public_ip
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.database.sql_server_name
}

output "deployment_info" {
  description = "Deployment summary information"
  value = {
    environment    = var.environment
    resource_group = azurerm_resource_group.main.name
    location      = var.location
    deployed_at   = timestamp()
  }
}