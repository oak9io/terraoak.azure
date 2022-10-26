variable "prefix" {
  default = "tfvmex"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  # oak9: microsoft_networkvirtual_networks.virtual_networks.address_space.address_prefixes is not configured
  # oak9: azurerm_virtual_network.tags is not configured
  # oak9: microsoft_networkvirtual_networks.virtual_networks.enable_ddos_protection is disabled, preventing protection of this virtual network from DDoS attacks
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "Attach"
    # SaC Testing - Severity: Critical - Set managed_disk_id to undefined
    managed_disk_id = ""

    # Note: 2 validations are written to check managed_disk is defined AND encryption
    # is defined. Encyrption is not mentioned in the tf so these will always fail
  }

# SaC Testing - Severity: Critical - Set storage_data_disk to undefined
storage_data_disk {
  name = "test-name"
  # SaC Testing - Severity: Critical - Set managed_disk_id to undefined
  managed_disk_id = "test-disk"

  # Note: this validation is also dependent on encryption which is undefined
}

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  
  os_profile_windows_config {
    # SaC Testing - Severity: High - Set winrm to undefined
    winrm {
        protocol = "HTTP"
    }

    # Note: validation is checking for defined listeners on winrm, this checks
    # the listener protocol which means there is an assumed listener present
  }
  tags = {
    environment = "staging"
  }
}