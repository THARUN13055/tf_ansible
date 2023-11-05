module "resource_group" {
  source        = "./module/resource"
  resource_name = local.resource_name
  location      = local.location
}

module "network" {
  source = "./module/network"

  virtual_network_name = "ansible-network"
  address_space        = "10.0.0.0/16"
  location             = local.location
  resource_name        = local.resource_name

  subnet_name = ["subnet1", "subnet2"]
  nsg_name = {
    "nsg-subnet1" = "subnet1"
    "nsg-subnet2" = "subnet2"
  }

  security_group_rules = [{
    id                          = 1,
    priority                    = "200",
    destination_port_range      = 22
    name                        = "ssh"
    network_security_group_name = "nsg-subnet1"
    },
    {
      id                          = 2,
      priority                    = "300",
      destination_port_range      = 80
      name                        = "http"
      network_security_group_name = "nsg-subnet1"
    },
    {
      id                          = 3,
      priority                    = "200",
      destination_port_range      = 22
      name                        = "ssh"
      network_security_group_name = "nsg-subnet2"
    }
  ]
  depends_on = [
    module.resource_group
  ]

}
# module/network
output "subnet_ids" {
  value = module.network.subnets_ids
}


module "machine" {
  source        = "./module/machine"
  resource_name = local.resource_name
  location      = local.location

  nic = {
    "nic1" = "slave1"
    "nic2" = "slave2"
  }
  vmsize      = "Standard_B1s"
  image_sku   = "22.04-LTS"
  subnets_ids = module.network.subnets_ids[*]
  file_path   = local.file_path
  depends_on = [
    module.network
  ]

}