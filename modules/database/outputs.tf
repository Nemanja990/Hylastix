output "server_id" {
  description = "PostgreSQL server ID"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_name" {
  description = "PostgreSQL server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Database name"
  value       = azurerm_postgresql_flexible_server_database.keycloak.name
}

output "admin_username" {
  description = "Administrator username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = azurerm_key_vault_secret.postgres_connection_string.value
  sensitive   = true
}

output "jdbc_url" {
  description = "JDBC URL for Keycloak"
  value       = azurerm_key_vault_secret.postgres_jdbc_url.value
  sensitive   = true
}