output "bastion_id" {
  description = "Bastion host ID"
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "Bastion host name"
  value       = azurerm_bastion_host.main.name
}

output "bastion_public_ip" {
  description = "Bastion public IP address"
  value       = azurerm_public_ip.bastion.ip_address
}