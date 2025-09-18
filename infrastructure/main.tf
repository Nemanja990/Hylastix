################################################################################
# Data Sources
################################################################################

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

################################################################################
# Local Variables
################################################################################

locals {
  project_name   = var.project_name
  environment    = var.environment
  location       = var.location
  location_short = var.location_short_map[var.location]
  
  name_prefix = "${local.project_name}-${local.environment}"
  
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

################################################################################
# Resource Group Module
################################################################################

module "resource_group" {
  source = "../modules/resource-group"
  
  name     = "rg-${local.name_prefix}-${local.location_short}"
  location = local.location
  tags     = local.common_tags
}

################################################################################
# Networking Module
################################################################################

module "network" {
  source = "../modules/network"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix         = local.name_prefix
  location_short      = local.location_short
  vnet_address_space  = var.vnet_address_space
  
  enable_bastion      = var.enable_bastion
  
  tags = local.common_tags
}

################################################################################
# Security Module (Key Vault & Managed Identity)
################################################################################

module "security" {
  source = "../modules/security"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix    = local.name_prefix
  location_short = local.location_short
  environment    = local.environment
  
  tags = local.common_tags
}

################################################################################
# Database Module (PostgreSQL)
################################################################################

module "database" {
  source = "../modules/database"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix    = local.name_prefix
  location_short = local.location_short
  environment    = local.environment
  
  subnet_id          = module.network.database_subnet_id
  private_dns_zone_id = module.network.postgres_dns_zone_id
  vnet_id            = module.network.vnet_id
  
  key_vault_id = module.security.key_vault_id
  
  postgres_sku        = var.postgres_sku
  postgres_storage_mb = var.postgres_storage_mb
  
  tags = local.common_tags
}

################################################################################
# Load Balancer Module
################################################################################

module "load_balancer" {
  source = "../modules/load-balancer"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix    = local.name_prefix
  location_short = local.location_short
  
  tags = local.common_tags
}

################################################################################
# Compute Module (VMSS)
################################################################################

module "compute" {
  source = "../modules/compute"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix    = local.name_prefix
  location_short = local.location_short
  
  subnet_id                  = module.network.app_subnet_id
  backend_address_pool_ids   = [module.load_balancer.backend_pool_id]
  health_probe_id            = module.load_balancer.health_probe_id
  
  vm_size            = var.vm_size
  instance_count     = var.instance_count
  min_instances      = var.min_instances
  max_instances      = var.max_instances
  availability_zones = var.availability_zones
  
  # Pass secrets and connection info via cloud-init
  keycloak_admin_password     = module.security.keycloak_admin_password
  postgres_connection_string  = module.database.connection_string
  postgres_jdbc_url          = module.database.jdbc_url
  key_vault_name             = module.security.key_vault_name
  
  ssh_public_key = module.security.ssh_public_key
  
  alert_email_addresses = var.alert_email_addresses
  
  tags = local.common_tags
}

################################################################################
# Monitoring Module
################################################################################

module "monitoring" {
  source = "../modules/monitoring"
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix = local.name_prefix
  environment = local.environment
  
  retention_days = var.environment == "prod" ? 90 : 30
  
  tags = local.common_tags
}

################################################################################
# Bastion Module (Optional)
################################################################################

module "bastion" {
  source = "../modules/bastion"
  
  count = var.enable_bastion ? 1 : 0
  
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  
  name_prefix = local.name_prefix
  subnet_id   = module.network.bastion_subnet_id
  
  tags = local.common_tags
}