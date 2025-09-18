variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for the backend."
  default     = "rg-terraform-state"
}

variable "location" {
  type        = string
  description = "Azure region for the backend resources."
  default     = "westeurope"
}

variable "storage_account_name_prefix" {
  type        = string
  description = "Prefix for the storage account name (must be unique globally)."
  default     = "tfstatekeycloak"
}

variable "container_name" {
  type        = string
  description = "Name of the blob container for state files."
  default     = "tfstate"
}