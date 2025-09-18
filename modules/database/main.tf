# Manages PostgreSQL Flexible Server

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
#   }
# }

################################################################################
# Random Password for PostgreSQL Admin
################################################################################

resource "random_password" "postgres_admin" {
  length  = 24
  special = true
  upper   = true
  lower   = true
  numeric = true
}

################################################################################
# PostgreSQL Flexible Server
################################################################################

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "psql-${var.name_prefix}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  version                       = "15"
  sku_name                     = var.postgres_sku
  storage_mb                   = var.postgres_storage_mb
  backup_retention_days        = var.environment == "prod" ? 30 : 7
  geo_redundant_backup_enabled = var.environment == "prod"
  
  administrator_login    = "keycloak"
  administrator_password = random_password.postgres_admin.result
  
  # High availability configuration
  dynamic "high_availability" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }
  zone = "1"
  
  # Network configuration - private access only
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = var.private_dns_zone_id
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      administrator_password,
      zone,
      high_availability
    ]
  }
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

################################################################################
# PostgreSQL Database
################################################################################

resource "azurerm_postgresql_flexible_server_database" "keycloak" {
  name      = "keycloak"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

################################################################################
# PostgreSQL Configurations
################################################################################

resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "max_connections"
  value     = "200"
}

resource "azurerm_postgresql_flexible_server_configuration" "shared_buffers" {
  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "shared_buffers"
  value     = "16384" # 128MB in 8KB units
}

resource "azurerm_postgresql_flexible_server_configuration" "work_mem" {
  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "work_mem"
  value     = "4096" # 4MB
}

################################################################################
# Store Secrets in Key Vault
################################################################################

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  name         = "postgres-connection-string"
  value        = "host=${azurerm_postgresql_flexible_server.main.fqdn} port=5432 dbname=keycloak user=${azurerm_postgresql_flexible_server.main.administrator_login} password=${random_password.postgres_admin.result} sslmode=require"
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}

resource "azurerm_key_vault_secret" "postgres_jdbc_url" {
  name         = "postgres-jdbc-url"
  value        = "jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/keycloak?sslmode=require"
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}