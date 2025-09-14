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