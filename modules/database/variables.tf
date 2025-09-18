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

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Delegated subnet ID for PostgreSQL"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "postgres_sku" {
  description = "PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B2ms"
}

variable "postgres_storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}