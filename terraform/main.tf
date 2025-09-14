# terraform/main.tf
# Generate random suffix for globally unique names
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Local values for naming
locals {
  suffix = random_integer.suffix.result
  
  common_tags = merge(var.tags, {
    Environment = var.environment
    DeployedBy  = "GitHub-Actions"
    CreatedOn   = timestamp()
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Call networking module
module "networking" {
  source = "./modules/networking"
  
  environment         = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet_address_space = var.vnet_address_space
  tags               = local.common_tags
}

# Call security module
module "security" {
  source = "./modules/security"
  
  environment         = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  suffix             = local.suffix
  tags               = local.common_tags
}

# Call compute module
module "compute" {
  source = "./modules/compute"
  
  environment         = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.networking.web_subnet_id
  vm_size            = var.vm_size
  key_vault_id       = module.security.key_vault_id
  suffix             = local.suffix
  tags               = local.common_tags
}

# Call database module
module "database" {
  source = "./modules/database"
  
  environment         = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id          = module.networking.data_subnet_id
  key_vault_id       = module.security.key_vault_id
  suffix             = local.suffix
  tags               = local.common_tags
}