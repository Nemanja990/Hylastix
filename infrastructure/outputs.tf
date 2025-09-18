# output "vnet_id" {
#   value = module.vnet.resource_id
# }

# output "subnet_ids" {
#   value = { for k, v in module.vnet.subnets : k => v.resource_id }
# }