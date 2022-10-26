
resource "azurerm_application_gateway" "randy_gateway" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    # SaC Testing - Severity: Critical - Set Policy != https
    protocol              = "Http"

    request_timeout       = 60
  }

  http_listener {
    name                           = "test1"
    frontend_ip_configuration_name = "ip_config_1"
    frontend_port_name             = "front_end_port_1"
    protocol                       = "HTTP1"
    port                           = 443
  }

  http_listener {
    name                           = "test2"
    frontend_ip_configuration_name = "ip_config_2"
    frontend_port_name             = "front_end_port_2"
    protocol                       = "HTTP2"
    port                           = 445
  }


  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    interval = 100
    name = "test-probe"

    # SaC Testing - Severity: Critical - Set Policy != https
    protocol = "http"

    path = "test-path"
    timeout = 100
    unhealthy_threshold = 2
  }

# Policy type and name can not be defined if disabled_protocols is
ssl_policy{

  # preferred values = ['TLSv1_0','TLSv1_1'] (misisng TLSv1_2 here)
  # SaC Testing - Severity: Critical - Set Policy != preferred value 
  disabled_protocols = ["tlsv2"]
  # SaC Testing - Severity: Critical - Set Policy !=  tlsv1_2
  min_protocol_version = "tlsv1_1"
}

}