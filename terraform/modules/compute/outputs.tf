# terraform/modules/compute/outputs.tf
output "web_vm_id" {
  description = "ID of the web VM"
  value       = azurerm_linux_virtual_machine.web_vm.id
}

output "web_vm_name" {
  description = "Name of the web VM"
  value       = azurerm_linux_virtual_machine.web_vm.name
}

output "app_vm_id" {
  description = "ID of the app VM"
  value       = azurerm_linux_virtual_machine.app_vm.id
}

output "app_vm_name" {
  description = "Name of the app VM"
  value       = azurerm_linux_virtual_machine.app_vm.name
}

output "web_vm_public_ip" {
  description = "Public IP address of the web VM"
  value       = azurerm_public_ip.web_vm.ip_address
}

output "web_vm_private_ip" {
  description = "Private IP address of the web VM"
  value       = azurerm_network_interface.web_vm.private_ip_address
}

output "app_vm_private_ip" {
  description = "Private IP address of the app VM"
  value       = azurerm_network_interface.app_vm.private_ip_address
}