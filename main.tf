provider "azurerm" {
  features {
  }
}

resource "azurerm_virtual_network" "azure-terraform" {
  name = var.azure-terraform
  location = "West Europe"
  resource_group_name = "rg-divansh-playground"
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
    address_prefixes = ["10.0.1.0/24"]
    name = "App-Subnet"
    virtual_network_name = azurerm_virtual_network.azure-terraform.name
    resource_group_name = "rg-divansh-playground"
}

resource "azurerm_subnet" "subnet2" {
    address_prefixes = ["10.0.2.0/24"]
    name = "Appgw-Subnet"
    virtual_network_name = azurerm_virtual_network.azure-terraform.name
    resource_group_name = "rg-divansh-playground"
}

resource "azurerm_dns_zone" "azure-terraform" {
  name = "DNS-test.com"
  resource_group_name = "rg-divansh-playground"
}

resource "azurerm_public_ip" "terraform" {
  name = "pip-test"
  resource_group_name = "rg-divansh-playground"
  location = "West Europe"
  allocation_method = "Static"
}

resource "azurerm_network_interface" "main" {
  name = "nic-interface1"
  location = "West Europe"
  resource_group_name = "rg-divansh-playground"

  ip_configuration {
    name = "testip1"
    subnet_id = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name = "test-vm"
  location = "West Europe"
  resource_group_name = "rg-divansh-playground"
  vm_size = "Standard_B1ls"
  network_interface_ids = [azurerm_network_interface.main.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

   os_profile {
    computer_name  = "Divyansh"
    admin_username = "Divyansh"
    admin_password = "Divyansh@123"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
}

