variable "virtual_network_name" {
  type = string
}

variable "address_space" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_name" {
  type = set(string)
}

variable "nsg_name" {
  type = map(string)
}

variable "security_group_rules" {
  type = list(any)
}