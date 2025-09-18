# modules/monitoring/main.tf - Monitoring Module
# Manages Log Analytics and Application Insights

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

################################################################################
# Log Analytics Workspace
################################################################################

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  daily_quota_gb      = var.environment == "prod" ? -1 : 1 # Unlimited for prod, 1GB cap for dev
  
  tags = var.tags
}

################################################################################
# Application Insights
################################################################################

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  
  daily_data_cap_in_gb                     = var.environment == "prod" ? 10 : 1
  daily_data_cap_notifications_disabled    = false
  retention_in_days                        = var.retention_days
  sampling_percentage                      = var.environment == "prod" ? 100 : 50
  disable_ip_masking                       = false
  
  tags = var.tags
}

################################################################################
# Log Analytics Solutions
################################################################################

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "vm_insights" {
  solution_name         = "VMInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
  
  tags = var.tags
}