resource "azurerm_virtual_network" "vnet" {
  name                = local.virtualnetworkname
  location            = local.location
  resource_group_name = local.resourcegroupname
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "appgwsubnet" {
  name                 = "appgw-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.5.0/29"]
}

resource "azurerm_subnet" "webtiersubnet" {
  name                 = "web-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "apptiersubnet" {
  name                 = "app-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "dbtiersubnet" {
  name                 = "db-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "managementtiersubnet" {
  name                 = "maanagement-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = local.resourcegroupname
  address_prefixes     = ["10.0.4.0/24"]
}