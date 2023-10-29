variable "resource_name" {
  type = string
}

variable "location" {
  type = string
}

variable "nic" {
  type = map(string)
}

variable "subnet_id" {
  type = string
}
