# Manages Key Vault, Managed Identity, and Secrets

# terraform {
#   required_version = ">= 1.6.0"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = "~> 3.6"
#     }
#     tls = {
#       source  = "hashicorp/tls"
#       version = "~> 4.0"
#     }
#   }
# }

################################################################################
# Data Sources
################################################################################

data "azurerm_client_config" "current" {}

################################################################################
# Key Vault
################################################################################

resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_key_vault" "main" {
  name                = "kv-${replace(var.name_prefix, "-", "")}${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  #enable_rbac_authorization       = true
  purge_protection_enabled        = var.environment == "prod"
  soft_delete_retention_days      = var.environment == "prod" ? 90 : 7
  
  network_acls {
    default_action = "Allow" # For assignment purposes; I would use "Deny" with IP rules in production
    bypass         = "AzureServices"
  }
  
  tags = var.tags
}

################################################################################
# User Assigned Managed Identity
################################################################################

# Note: As you mentioned, this might be provided externally
# Including it here for completeness but can be removed if provided
# resource "azurerm_user_assigned_identity" "vm" {
#   name                = "id-vm-${var.name_prefix}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
  
#   tags = var.tags
# }

################################################################################
# SSH Key Pair
################################################################################

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

################################################################################
# Keycloak Admin Password
################################################################################

resource "random_password" "keycloak_admin" {
  length  = 24
  special = true
  upper   = true
  lower   = true
  numeric = true
}

################################################################################
# Store Secrets in Key Vault
################################################################################

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "vm-ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.main.id
  
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "vm-ssh-public-key"
  value        = tls_private_key.ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.main.id
  
}

resource "azurerm_key_vault_secret" "keycloak_admin_password" {
  name         = "keycloak-admin-password"
  value        = random_password.keycloak_admin.result
  key_vault_id = azurerm_key_vault.main.id
  
}