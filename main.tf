locals {
  resourcegroupname  = "CISCloudNativeAppInfra-2088801-RG"
  location           = "centralus"
  virtualnetworkname = "azcu-vnet-tier"
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "azcu-bastion-pip"
  resource_group_name = local.resourcegroupname
  location            = local.location
  allocation_method   = "Static"
}
resource "azurerm_bastion_host" "bation-host" {
  name                = "bation-host"
  location            = local.location
  resource_group_name = local.resourcegroupname

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

resource "azurerm_network_interface" "management-nic" {
  name                = "management-nic"
  resource_group_name = local.resourcegroupname
  location            = local.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.managementtiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.4.4"
  }
}

resource "azurerm_windows_virtual_machine" "management-vm" {
  name                  = "management-vm"
  resource_group_name   = local.resourcegroupname
  location              = local.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "Cognizant@12345"
  network_interface_ids = [azurerm_network_interface.management-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_network_interface" "web-nic" {
  name                = "web-nic"
  resource_group_name = local.resourcegroupname
  location            = local.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.webtiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

resource "azurerm_windows_virtual_machine" "web-vm" {
  name                  = "web-vm"
  resource_group_name   = local.resourcegroupname
  location              = local.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "Cognizant@12345"
  network_interface_ids = [azurerm_network_interface.web-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "web-vm-iis" {
  name                       = "web-vm-iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.web-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command Install-WindowsFeature -Name Web-Server -IncludeManagementTools;netsh advfirewall firewall add rule name='AllowInBoundHTTP' dir=in action=allow protocol=TCP localport=80;netsh advfirewall firewall add rule name='AllowInBoundHTTPs' dir=in action=allow protocol=TCP localport=443;"
  }
  SETTINGS
}

resource "azurerm_network_interface" "app-nic" {
  name                = "app-nic"
  resource_group_name = local.resourcegroupname
  location            = local.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.apptiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
  }
}

resource "azurerm_windows_virtual_machine" "app-vm" {
  name                  = "app-vm"
  resource_group_name   = local.resourcegroupname
  location              = local.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "Cognizant@12345"
  network_interface_ids = [azurerm_network_interface.app-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_virtual_machine_extension" "app-vm-iis" {
  name                       = "app-vm-iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.app-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command Install-WindowsFeature -Name Web-Server -IncludeManagementTools;netsh advfirewall firewall add rule name='AllowInBoundHTTP' dir=in action=allow protocol=TCP localport=80;netsh advfirewall firewall add rule name='AllowInBoundHTTPs' dir=in action=allow protocol=TCP localport=443;"
  }
  SETTINGS
}

resource "azurerm_network_interface" "db-nic" {
  name                = "db-nic"
  resource_group_name = local.resourcegroupname
  location            = local.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dbtiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.4"
  }
}

resource "azurerm_windows_virtual_machine" "db-vm" {
  name                  = "db-vm"
  resource_group_name   = local.resourcegroupname
  location              = local.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = "Cognizant@12345"
  network_interface_ids = [azurerm_network_interface.db-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2019-ws2022"
    sku       = "Enterprise"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "db-vm-firewall" {
  name                       = "db-vm-iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.db-vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command netsh advfirewall firewall add rule name='AllowInBoundDB' dir=in action=allow protocol=TCP localport=1433;"
  }
  SETTINGS
}