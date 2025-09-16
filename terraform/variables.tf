# terraform/variables.tf
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "uk south"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_monitoring" {
  description = "Enable monitoring and diagnostics"
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Size of virtual machines"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "DevOps-Pipeline"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
# terraform/variables.tf
# Add these new variables to your existing file

# Database variables
variable "database_sku" {
  description = "Azure SQL Database SKU"
  type        = string
  default     = "Basic"
  
  validation {
    condition = contains([
      "Basic", "S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12",
      "P1", "P2", "P4", "P6", "P11", "P15"
    ], var.database_sku)
    error_message = "Database SKU must be a valid Azure SQL Database tier."
  }
}

variable "web_subnet_cidr" {
  description = "CIDR block for web tier subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "app_subnet_cidr" {
  description = "CIDR block for application tier subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "data_subnet_cidr" {
  description = "CIDR block for data tier subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Security variables
variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
  default     = []
}