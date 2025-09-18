output "lb_id" {
  description = "Load Balancer ID"
  value       = azurerm_lb.main.id
}

output "lb_name" {
  description = "Load Balancer name"
  value       = azurerm_lb.main.name
}

output "public_ip_id" {
  description = "Public IP ID"
  value       = azurerm_public_ip.lb.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.lb.ip_address
}

output "backend_pool_id" {
  description = "Backend address pool ID"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "health_probe_id" {
  description = "Health probe ID"
  value       = azurerm_lb_probe.http.id
}