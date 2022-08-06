provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

locals {
  tags = {
    project = "resources"
  }
}

#============================================================================
#image created from packers
data "azurerm_image" "webserver" {
  name                = "WebServerImage"
  resource_group_name = var.resource_group
}

#============================================================================
#create the resource group, already taken from codelab

resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
}

#============================================================================
#create a virtual network

resource "azurerm_virtual_network" "main" {
  name                = "${var.resource_group}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = local.tags
}

#============================================================================
#create the subnets

resource "azurerm_subnet" "main" {
  name                 = "${var.resource_group}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#============================================================================
#create the network security group

resource "azurerm_network_security_group" "main" {
  name                = "${var.resource_group}-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags = local.tags
}

#============================================================================
# create network security rules

resource "azurerm_network_security_rule" "DenyInboundInternet" {
  name                        = "${var.resource_group}-inbound-deny-SR"
  destination_address_prefix  = "Internet"
  source_address_prefix       = "0.0.0.0/0"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  destination_port_range      = "*"
  source_port_range           = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "AllowInboundVM" {
  name                         = "${var.resource_group}-inbound-allow-vm-SR"
  destination_address_prefix   = "VirtualNetwork"
  source_address_prefix        = "VirtualNetwork"
  priority                     = 101
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_ranges           = azurerm_virtual_network.main.address_space
  destination_port_ranges      = azurerm_virtual_network.main.address_space
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "AllowOutboundVM" {
  name                         = "${var.resource_group}-outbound-allow-vm-SR"
  destination_address_prefix   = "VirtualNetwork"
  source_address_prefix        = "VirtualNetwork"
  priority                     = 102
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_ranges           = azurerm_virtual_network.main.address_space
  destination_port_ranges      = azurerm_virtual_network.main.address_space
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "AllowInboundLB" {
  name                         = "${var.resource_group}-inbound-allow-lb-SR"
  destination_address_prefix   = "VirtualNetwork"
  source_address_prefix        = "AzureLoadBalancer"
  priority                     = 103
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_ranges           = azurerm_virtual_network.main.address_space
  destination_port_ranges      = azurerm_virtual_network.main.address_space
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

#============================================================================
#create network interface

resource "azurerm_network_interface" "main" {
  count               = var.number_of_vm
  name                = "${var.resource_group}-${count.index}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

#============================================================================
#create public ip address

resource "azurerm_public_ip" "main" {
  name                = "${var.resource_group}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags                = local.tags
}

#============================================================================
#create a load balancer

resource "azurerm_lb" "main" {
  name                = "${var.resource_group}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

#============================================================================
#load balancer will use the below backend pool

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "${var.resource_group}-lb-backend-pool"
}

#============================================================================
#for backend pool association

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.number_of_vm
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

#============================================================================
#create virtual machine availability security

resource "azurerm_availability_set" "main" {
  name                = "${var.resource_group}-aset"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags
}

#============================================================================
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.number_of_vm
  name                            = "${var.resource_group}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    element(azurerm_network_interface.main.*.id,count.index)
  ]
  availability_set_id             = azurerm_availability_set.main.id

  source_image_id = data.azurerm_image.webserver.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = local.tags
}
