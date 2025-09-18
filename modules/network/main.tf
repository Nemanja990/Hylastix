# modules/network/main.tf - Network Module
# Manages VNet, Subnets, NSGs, and DNS

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
# Virtual Network
################################################################################

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.name_prefix}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  
  tags = var.tags
}

################################################################################
# Subnets
################################################################################

# Application Subnet - For VMs running containers
resource "azurerm_subnet" "app" {
  name                 = "snet-app-${var.name_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 0)] # /20 - 4,096 IPs
  
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]
}

# Database Subnet - For PostgreSQL Flexible Server
resource "azurerm_subnet" "database" {
  name                 = "snet-db-${var.name_prefix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 1)] # /20
  
  delegation {
    name = "postgresql"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  
  service_endpoints = [
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 15)] # /20 - Last subnet
}

################################################################################
# Network Security Groups
################################################################################

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

# NSG Rules for Application Subnet
resource "azurerm_network_security_rule" "allow_http_from_lb" {
  name                        = "AllowHttpFromLB"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "allow_https_from_lb" {
  name                        = "AllowHttpsFromLB"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "allow_keycloak_from_lb" {
  name                        = "AllowKeycloakFromLB"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "8443"]
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "allow_ssh_from_bastion" {
  name                        = "AllowSSHFromBastion"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.enable_bastion ? azurerm_subnet.bastion[0].address_prefixes[0] : "AzureCloud"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "allow_health_probe" {
  name                        = "AllowHealthProbe"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "168.63.129.16" # Azure health probe IP
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

# Associate NSG with Application Subnet
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

################################################################################
# Private DNS Zone for PostgreSQL
################################################################################

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  
  tags = var.tags
}