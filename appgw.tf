resource "azurerm_public_ip" "pip" {
  name                = "appgw-pip"
  resource_group_name = local.resourcegroupname
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "app-gw"
  resource_group_name = local.resourcegroupname
  location            = local.location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "ipconfig"
    subnet_id = azurerm_subnet.appgwsubnet.id
  }
  frontend_port {
    name = "frontendPort"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontendIPConfig"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  backend_address_pool {
    name = "backendPool"
  }
  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendIPConfig"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }
 request_routing_rule {
    name                       = "routingRule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSettings"
  }
}