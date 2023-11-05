module "resource_group" {
  source        = "../resource"
  resource_name = var.resource_name
  location      = var.location
}

resource "azurerm_network_interface" "network-interface" {
  for_each            = var.nic
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_name

  ip_configuration {
    name                          = "${each.key}-ipconfig"
    subnet_id                     = join(",", var.subnets_ids)
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    module.resource_group
  ]
}

resource "azurerm_virtual_machine" "linux" {
  for_each              = var.nic
  name                  = each.value
  location              = var.location
  resource_group_name   = var.resource_name
  network_interface_ids = [azurerm_network_interface.network-interface[each.key].id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.image_sku
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${each.value}-compute"
    admin_username = "tharun"
    custom_data    = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/tharun/.ssh/authorized_keys"
      key_data = file(var.file_path)
    }
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = [azurerm_network_interface.network-interface[each.key].id]
      password = ""
      private_key = "/home/tharun/.ssh/authorized_keys"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${azurerm_network_interface.network-interface[each.key].id}, --private-key ${var.file_path} ./ansible/docker.yaml"
  }
  depends_on = [
    module.resource_group
  ]
}