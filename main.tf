provider "azurerm" {
  features {
  }
}

resource "azurerm_virtual_network" "azure-terraform" {
  name = var.azure-terraform
  location = var.location
  resource_group_name = var.rg_name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
    address_prefixes = ["10.0.1.0/24"]
    name = "App-Subnet"
    virtual_network_name = azurerm_virtual_network.azure-terraform.name
    resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet2" {
    address_prefixes = ["10.0.2.0/24"]
    name = "AppGw-Subnet"
    virtual_network_name = azurerm_virtual_network.azure-terraform.name
    resource_group_name = var.rg_name
}

# resource "azurerm_dns_zone" "azure-terraform" {
#   name = "DNS-test.com"
#   resource_group_name = "rg-divansh-playground"
# }

resource "azurerm_public_ip" "terraform" {
  name = "pip-test"
  resource_group_name = var.rg_name
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_public_ip" "terraform-2" {
  name = "pip-test2"
  resource_group_name = var.rg_name
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_interface" "main" {
  name = "nic-interface1"
  location = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name = "testip1"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.terraform-2.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name = "test-vm"
  location = var.location
  resource_group_name = var.rg_name
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
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
}

resource "azurerm_network_security_group" "test_nsg" {
  name                = "test-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "allowssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

   security_rule {
    name                       = "allowhttp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}

locals {
  backend_address_pool_name      = "${var.locals-name}-beap"
  frontend_port_name             = "${var.locals-name}-feport"
  frontend_ip_configuration_name = "${var.locals-name}-feip"
  http_setting_name              = "${var.locals-name}-be-htst"
  listener_name                  = "${var.locals-name}-httplstn"
  request_routing_rule_name      = "${var.locals-name}-rqrt"
  redirect_configuration_name    = "${var.locals-name}-rdrcfg"
}

resource "azurerm_application_gateway" "gateway_1" {
  name = "Appgate-agw"
  resource_group_name = var.rg_name
  location = var.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet2.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.terraform.id
  }

   backend_address_pool {
    name = local.backend_address_pool_name
  }

   backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

   http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority = 1
  }
}

resource "azurerm_virtual_network" "azure-terraform_2" {
  name = "Hub-Vnet"
  location = var.location
  resource_group_name = var.rg_name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet3" {
    address_prefixes = ["10.0.2.0/24"]
    name = "AzureFirewallSubnet"
    virtual_network_name = azurerm_virtual_network.azure-terraform_2.name
    resource_group_name = var.rg_name
}

resource "azurerm_public_ip" "firewall_ip" {
  name                = "firewall_testpip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall1" {
  name                = "testfirewall"
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "firwall_configuration"
    subnet_id            = azurerm_subnet.subnet3.id
    public_ip_address_id = azurerm_public_ip.firewall_ip.id
  }
}

resource "azurerm_route_table" "route1" {
  name                = "acceptanceTestRouteTable1"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_route" "route1" {
  name                = "acceptanceTestRoute1"
  resource_group_name = var.rg_name
  route_table_name    = azurerm_route_table.route1.name
  address_prefix      = "10.1.0.0/16"
  next_hop_type       = "VnetLocal"
}

resource "azurerm_key_vault" "key1" {
  name = "key654"
  resource_group_name = var.rg_name
  location = var.location
  sku_name = "standard"
  tenant_id = var.tenant
}