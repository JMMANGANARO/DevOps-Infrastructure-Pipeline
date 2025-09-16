# terraform/modules/security/outputs.tf
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = azurerm_user_assigned_identity.vm_identity.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.vm_identity.principal_id
}

output "vm_admin_password_secret_name" {
  description = "Name of the VM admin password secret"
  value       = azurerm_key_vault_secret.vm_admin_password.name
}

output "sql_admin_password_secret_name" {
  description = "Name of the SQL admin password secret"
  value       = azurerm_key_vault_secret.sql_admin_password.name
}