# Manages Virtual Machine Scale Set and Autoscaling

# terraform {
#   required_version = ">= 1.6.0"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#   }
# }

################################################################################
# Virtual Machine Scale Set
################################################################################

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "vmss-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = var.instance_count
  zones               = var.availability_zones
  zone_balance        = true
  
  admin_username = "azureuser"
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  network_interface {
    name    = "nic"
    primary = true
    
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.backend_address_pool_ids
    }
  }
  
  identity {
    type         = "SystemAssigned"
  }
  
  # Cloud-init configuration for container setup
  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml", {
    keycloak_admin_password    = var.keycloak_admin_password
    postgres_connection_string = var.postgres_connection_string
    postgres_jdbc_url          = var.postgres_jdbc_url
    key_vault_name            = var.key_vault_name
  }))
  
  # Automatic OS upgrades
  automatic_os_upgrade_policy {
    enable_automatic_os_upgrade = true
    disable_automatic_rollback  = false
  }
  
  # Rolling upgrade policy
  upgrade_mode = "Automatic"
  
  health_probe_id = var.health_probe_id
  
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [instances]
  }
}

################################################################################
# Autoscale Settings
################################################################################

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "autoscale-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id
  enabled             = true
  
  profile {
    name = "defaultProfile"
    
    capacity {
      default = var.instance_count
      minimum = var.min_instances
      maximum = var.max_instances
    }
    
    # Scale out when CPU > 70%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    
    # Scale in when CPU < 30%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
  
  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = var.alert_email_addresses
    }
  }
  
  tags = var.tags
}