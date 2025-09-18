variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location_short" {
  description = "Short location code"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for VMs"
  type        = string
}

variable "backend_address_pool_ids" {
  description = "Load balancer backend pool IDs"
  type        = list(string)
}

variable "health_probe_id" {
  description = "Load balancer health probe ID"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "instance_count" {
  description = "Initial number of instances"
  type        = number
  default     = 2
}

variable "min_instances" {
  description = "Minimum instances for autoscaling"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum instances for autoscaling"
  type        = number
  default     = 5
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "postgres_connection_string" {
  description = "PostgreSQL connection string"
  type        = string
  sensitive   = true
}

variable "postgres_jdbc_url" {
  description = "PostgreSQL JDBC URL"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "alert_email_addresses" {
  description = "Email addresses for alerts"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}