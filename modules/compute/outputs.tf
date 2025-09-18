output "vmss_id" {
  description = "Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

output "vmss_name" {
  description = "Virtual Machine Scale Set name"
  value       = azurerm_linux_virtual_machine_scale_set.main.name
}

output "vmss_principal_id" {
  description = "VMSS identity principal ID"
  value       = azurerm_linux_virtual_machine_scale_set.main.identity[0].principal_id
}