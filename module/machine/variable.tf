variable "resource_name" {
  type = string
}

variable "location" {
  type = string
}

variable "nic" {
  type = map(string)
}

variable "subnets_ids" {
  type = any
}

variable "vmsize" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "file_path" {
  type      = string
  sensitive = true
}