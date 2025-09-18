output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "ssh_public_key" {
  description = "SSH public key for VM access"
  value       = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key" {
  description = "SSH private key for VM access"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "keycloak_admin_password" {
  description = "Keycloak admin password"
  value       = random_password.keycloak_admin.result
  sensitive   = true
}