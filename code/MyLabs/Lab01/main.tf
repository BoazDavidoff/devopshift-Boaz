provider "azurerm" {
  features {}
}

variable "location" {
  default = "East US"
}

variable "myname" {
    default = "boaz"
}

resource "azurerm_resource_group" "rg-boaz" {
  name     = "${var.myname}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-boaz" {
  name                = "${var.myname}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-boaz.name
}

resource "azurerm_subnet" "subnet-boaz" {
  name                 = "${var.myname}-subnet"
  resource_group_name  = azurerm_resource_group.rg-boaz.name
  virtual_network_name = azurerm_resource_group.rg-boaz.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-boaz" {
  name                = "${var.myname}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-boaz.name
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}


resource "azurerm_network_interface" "nic-boaz" {
  name                = "${var.myname}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-boaz.name

  ip_configuration {
    name                          = "${var.myname}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-boaz.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-boaz.id
  }
}

