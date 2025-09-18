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

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "lb_rules" {
  type = map(object({
    name           = string
    frontend_port  = number
    backend_port   = number
  }))
  default = {
    http = {
      name          = "http"
      frontend_port = 80
      backend_port  = 80
    }
    https = {
      name          = "https"
      frontend_port = 443
      backend_port  = 443
    }
    keycloak_http = {
      name          = "keycloak-http"
      frontend_port = 8080
      backend_port  = 8080
    }
    keycloak_https = {
      name          = "keycloak-https"
      frontend_port = 8443
      backend_port  = 8443
    }
  }
  description = "A map of load balancer rules to create dynamically."
}