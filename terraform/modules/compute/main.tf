# terraform/modules/compute/main.tf

# Get VM admin password from Key Vault
data "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  key_vault_id = var.key_vault_id
}

# Public IP for Web VM (so we can access it from internet)
resource "azurerm_public_ip" "web_vm" {
  name                = "pip-vm-web-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

# Network Interface for Web VM
resource "azurerm_network_interface" "web_vm" {
  name                = "nic-vm-web-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags               = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_vm.id
  }
}

# Web Virtual Machine
resource "azurerm_linux_virtual_machine" "web_vm" {
  name                = "vm-web-${var.environment}-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = "azureuser"
  
  # Disable password authentication, use SSH keys instead (more secure)
  disable_password_authentication = false
  admin_password                 = data.azurerm_key_vault_secret.vm_admin_password.value
  
  tags = merge(var.tags, {
    Tier = "Web"
    Role = "WebServer"
  })

  network_interface_ids = [
    azurerm_network_interface.web_vm.id,
  ]

  # VM Disk Configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # Fast SSD storage
    disk_size_gb        = 30
  }

  # Operating System
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Install web server automatically when VM starts
  custom_data = base64encode(templatefile("${path.module}/cloud-init-web.yml", {
    environment = var.environment
  }))

  # VM Identity (so it can access Key Vault)
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  depends_on = [
    azurerm_network_interface.web_vm
  ]
}

# Network Interface for App VM (no public IP - internal only)
resource "azurerm_network_interface" "app_vm" {
  name                = "nic-vm-app-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags               = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public IP - internal only for security
  }
}

# Application Virtual Machine
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "vm-app-${var.environment}-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = "azureuser"
  
  disable_password_authentication = false
  admin_password                 = data.azurerm_key_vault_secret.vm_admin_password.value
  
  tags = merge(var.tags, {
    Tier = "Application"
    Role = "AppServer"
  })

  network_interface_ids = [
    azurerm_network_interface.app_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb        = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Install application server software
  custom_data = base64encode(templatefile("${path.module}/cloud-init-app.yml", {
    environment = var.environment
  }))

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  depends_on = [
    azurerm_network_interface.app_vm
  ]
}

# VM Extensions for monitoring (optional but good practice)
resource "azurerm_virtual_machine_extension" "web_vm_monitor" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.web_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "app_vm_monitor" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.app_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}