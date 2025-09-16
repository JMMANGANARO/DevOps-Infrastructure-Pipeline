# modules/database/variables.tf
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for private endpoint"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault for storing secrets"
  type        = string
}

variable "suffix" {
  description = "Random suffix for unique naming"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "database_sku" {
  description = "Database SKU/pricing tier"
  type        = string
  default     = "Basic"  # Cost-effective for learning
}

variable "admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
}