# output "subnets_ids" {
#   value = azurerm_subnet.virtual_subnet[subnet1].id
# }

# output "subnet_ids2" {
#   value = azurerm_subnet.virtual_subnet[subnet2].id
# }

output "subnets_ids" {
  value = values(azurerm_subnet.virtual_subnet)[*].id
}