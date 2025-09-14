# terraform/modules/networking/outputs.tf
output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = azurerm_subnet.data.id
}

output "web_subnet_cidr" {
  description = "CIDR of the web subnet"
  value       = azurerm_subnet.web.address_prefixes[0]
}

output "app_subnet_cidr" {
  description = "CIDR of the app subnet"
  value       = azurerm_subnet.app.address_prefixes[0]
}

output "data_subnet_cidr" {
  description = "CIDR of the data subnet"
  value       = azurerm_subnet.data.address_prefixes[0]
}