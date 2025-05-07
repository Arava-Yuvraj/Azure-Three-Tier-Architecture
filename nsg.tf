resource "azurerm_network_security_group" "webtiernsg" {
  name                = "web-nsg"
  location            = local.location
  resource_group_name = local.resourcegroupname

  security_rule {
    name                       = "AllowInBoundAppGW"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    source_address_prefix      = "10.0.5.0/29"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "AllowInBoundHttpHttps"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "AllowInboundManagementSubnetRDP"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "DenyAllowInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "webtier-nsg-associate" {
  subnet_id                 = azurerm_subnet.webtiersubnet.id
  network_security_group_id = azurerm_network_security_group.webtiernsg.id
}

resource "azurerm_network_security_group" "apptiernsg" {
  name                = "app-nsg"
  location            = local.location
  resource_group_name = local.resourcegroupname

  security_rule {
    name                       = "AllowInboundAppLB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.2.5"
  }
  security_rule {
    name                       = "AllowInboundwebsubnethttps"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "AllowInboundManagementSubnetRDP"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }

  security_rule {
    name                       = "DenyAllowInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "apptier-nsg-associate" {
  subnet_id                 = azurerm_subnet.apptiersubnet.id
  network_security_group_id = azurerm_network_security_group.apptiernsg.id
}

resource "azurerm_network_security_group" "dbtiernsg" {
  name                = "db-nsg"
  location            = local.location
  resource_group_name = local.resourcegroupname

  security_rule {
    name                       = "AllowInboundwebsubnetDBLB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.3.5"
  }
    security_rule {
    name                       = "AllowInboundwebsubnetDB"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }
  security_rule {
    name                       = "AllowInboundManagementSubnetRDP"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "10.0.3.0/24"
  }
  security_rule {
    name                       = "DenyAllowInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "dbtier-nsg-associate" {
  subnet_id                 = azurerm_subnet.dbtiersubnet.id
  network_security_group_id = azurerm_network_security_group.dbtiernsg.id
}

resource "azurerm_network_security_group" "managementtiernsg" {
  name                = "management-nsg"
  location            = local.location
  resource_group_name = local.resourcegroupname
  security_rule {
    name                       = "AllowInboundManagementSubnetRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/26"
    destination_address_prefix = "10.0.4.0/24"
  }

  security_rule {
    name                       = "DenyAllowInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "managementtier-nsg-associate" {
  subnet_id                 = azurerm_subnet.managementtiersubnet.id
  network_security_group_id = azurerm_network_security_group.managementtiernsg.id
}