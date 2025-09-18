output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Virtual Network address space"
  value       = azurerm_virtual_network.main.address_space
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = azurerm_subnet.app.id
}

output "database_subnet_id" {
  description = "Database subnet ID"
  value       = azurerm_subnet.database.id
}

output "bastion_subnet_id" {
  description = "Bastion subnet ID"
  value       = var.enable_bastion ? azurerm_subnet.bastion[0].id : null
}

output "app_nsg_id" {
  description = "Application NSG ID"
  value       = azurerm_network_security_group.app.id
}

output "postgres_dns_zone_id" {
  description = "PostgreSQL Private DNS Zone ID"
  value       = azurerm_private_dns_zone.postgres.id
}