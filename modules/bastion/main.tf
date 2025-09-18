# modules/bastion/main.tf - Bastion Module
# Optional module for secure VM access

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
  
  tags = var.tags
}