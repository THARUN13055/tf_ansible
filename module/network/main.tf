module "resource" {
  source        = "../resource"
  resource_name = var.resource_name
  location      = var.location
}


resource "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_name
  depends_on = [
    module.resource
  ]
}

resource "azurerm_subnet" "virtual_subnet" {
  for_each             = var.subnet_name
  name                 = each.key
  resource_group_name  = var.resource_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, index(tolist(var.subnet_name), each.key))]
  depends_on = [
    module.resource,
    azurerm_virtual_network.virtual_network
  ]
}

resource "azurerm_subnet_network_security_group_association" "security_group_association" {
  for_each                  = var.nsg_name
  subnet_id                 = azurerm_subnet.virtual_subnet[each.value].id
  network_security_group_id = azurerm_network_security_group.security_group[each.key].id
}

resource "azurerm_network_security_group" "security_group" {
  for_each            = var.nsg_name
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_name
}


resource "azurerm_network_security_rule" "security_rules" {
  for_each                    = { for rule in var.security_group_rules : rule.id => rule }
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_name
  network_security_group_name = azurerm_network_security_group.security_group[each.value.network_security_group_name].id
}