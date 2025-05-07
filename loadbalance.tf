resource "azurerm_lb" "app-lb" {
  name                = "app-lb"
  resource_group_name = local.resourcegroupname
  location            = local.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    subnet_id                     = azurerm_subnet.apptiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
  }
}

resource "azurerm_lb_backend_address_pool" "app-backend-pool" {
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.app-lb.id
}

# Backend IP Addresses
resource "azurerm_lb_backend_address_pool_address" "app_backend_ips" {
  name = "app-backend-pool-address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app-backend-pool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address               = "10.0.2.4"
}

resource "azurerm_lb_probe" "app_http_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.app-lb.id
  protocol            = "Http"
  request_path        = "/"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "app_https_probe" {
  name                = "https-probe"
  loadbalancer_id     = azurerm_lb.app-lb.id
  protocol            = "Https"
  request_path        = "/"
  port                = 443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "app_http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.app-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.app-lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app-backend-pool.id]
  probe_id                       = azurerm_lb_probe.app_http_probe.id
  idle_timeout_in_minutes        = 4
}

resource "azurerm_lb_rule" "app_https_rule" {
  name                           = "https-rule"
  loadbalancer_id                = azurerm_lb.app-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.app-lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app-backend-pool.id]
  probe_id                       = azurerm_lb_probe.app_https_probe.id
  idle_timeout_in_minutes        = 4
}

resource "azurerm_lb" "db-lb" {
  name                = "db-lb"
  resource_group_name = local.resourcegroupname
  location            = local.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    subnet_id                     = azurerm_subnet.dbtiersubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.5"
  }
}

resource "azurerm_lb_backend_address_pool" "db-backend-pool" {
  name            = "db-backend-pool"
  loadbalancer_id = azurerm_lb.db-lb.id
}

# Backend IP Addresses
resource "azurerm_lb_backend_address_pool_address" "db_backend_ips" {
  name = "db-backend-pool-address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.db-backend-pool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address               = "10.0.3.4"
}
resource "azurerm_lb_probe" "db_mssql_probe" {
  name                = "mssql-probe"
  loadbalancer_id     = azurerm_lb.db-lb.id
  protocol            = "Tcp"
  port                = 1433
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "mssql_rule" {
  name                           = "msql-rule"
  loadbalancer_id                = azurerm_lb.db-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = azurerm_lb.db-lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.db-backend-pool.id]
  probe_id                       = azurerm_lb_probe.db_mssql_probe.id
  idle_timeout_in_minutes        = 4
}