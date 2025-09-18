# Manages Azure Load Balancer for high availability

# terraform {
#   required_version = ">= 1.6.0"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#   }
# }

################################################################################
# Public IP for Load Balancer
################################################################################

resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  
  tags = var.tags
}

################################################################################
# Load Balancer
################################################################################

resource "azurerm_lb" "main" {
  name                = "lb-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
  
  tags = var.tags
}

################################################################################
# Backend Pool
################################################################################

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

################################################################################
# Health Probes
################################################################################

resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http-probe"
  port                = 8080
  protocol            = "Http"
  request_path        = "/health"
  interval_in_seconds = 15
  number_of_probes    = 2
}

################################################################################
# Load Balancing Rules
################################################################################

resource "azurerm_lb_rule" "main" {
  for_each = var.lb_rules

  loadbalancer_id                = azurerm_lb.main.id
  name                           = each.value.name
  protocol                       = "Tcp"
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
  idle_timeout_in_minutes        = 4
}

################################################################################
# Outbound Rule for SNAT
################################################################################

resource "azurerm_lb_outbound_rule" "main" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.main.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  allocated_outbound_ports = 1024
  idle_timeout_in_minutes  = 4
  
  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}