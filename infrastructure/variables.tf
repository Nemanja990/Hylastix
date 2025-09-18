variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "keycloak"
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "Project name must be 3-20 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "location_short_map" {
  description = "Map of Azure regions to short codes"
  type        = map(string)
  default = {
    "West Europe"         = "weu"
    "North Europe"        = "neu"
    "UK South"           = "uks"
    "UK West"            = "ukw"
    "East US"            = "eus"
    "West US"            = "wus"
    "Central US"         = "cus"
    "France Central"     = "frc"
    "Germany West Central" = "gwc"
  }
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type = string
  default = "10.0.0.1/16"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = { "Environment" = "Testing" }
}

variable "enable_bastion" {
  type = bool
  default = true
}

variable "postgres_sku" {
  type        = string
  description = "The SKU for the PostgreSQL Flexible Server."
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  type        = number
  description = "The storage size in MB for the PostgreSQL server."
  default     = 32768
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine Scale Set instances."
  default     = "Standard_DS1_v2"
}

variable "instance_count" {
  type        = number
  description = "The initial number of VM instances in the scale set."
  default     = 2
}

variable "min_instances" {
  type        = number
  description = "The minimum number of VM instances in the scale set."
  default     = 1
}

variable "max_instances" {
  type        = number
  description = "The maximum number of VM instances in the scale set."
  default     = 5
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to use for the VMSS."
  default     = ["1", "2"]
}

variable "alert_email_addresses" {
  type        = list(string)
  description = "List of email addresses for alerts."
  default     = []
}