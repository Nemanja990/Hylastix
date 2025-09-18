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

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_bastion" {
  description = "Enable Azure Bastion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}