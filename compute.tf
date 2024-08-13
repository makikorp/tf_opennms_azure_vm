# Generate random text for a unique storage account name
#resource "random_id" "random_id" {
#  keepers = {
#    # Generate a new ID only when a new resource group is defined
#    resource_group = azurerm_resource_group.rg.name
#  }
#
#  byte_length = 8
#}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS3_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "erockyenterprisesoftwarefoundationinc1653071250513"
    offer     = "rockylinux-9"
    sku       = "rockylinux-9"
    version   = "9.0.0"
  }

  plan {
    name = "rockylinux-9"
    product = "rockylinux-9"
    publisher = "erockyenterprisesoftwarefoundationinc1653071250513"
  }

  computer_name  = "rockyMeridian"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    #key = var.key_name
    public_key = file(var.public_key_path)
    #public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

}

resource "local_file" "public_ip_address"{
  content = "[main]\n${azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address}"
  filename = "azure_hosts"
}

#Call and run Ansible playbook
resource "null_resource" "opennms_install" {
  
  provisioner "local-exec" {
    command = "ansible-playbook -i /users/emaki/code/tf_opennms_azure_vm/azure_hosts --key-file /Users/emaki/.ssh/ericTFazure playbooks/opennms.yml"
  }
  depends_on = [
    azurerm_linux_virtual_machine.my_terraform_vm
  ]

}




