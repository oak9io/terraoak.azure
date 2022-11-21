
resource "azurerm_application_gateway" "example_app_gateway" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Required
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  # Required
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  # Required
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # Required
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }
  
  # Required
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  # Required
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Https"

    authentication_certificate {
    }

    trusted_root_certificate {
    }
    request_timeout       = 60
  }

  # Required
  http_listener {
    name                           = "test1"
    frontend_ip_configuration_name = "ip_config_1"
    frontend_port_name             = "front_end_port_1"
    protocol                       = "HTTP"
    port                           = 80
  }

  http_listener {
    name                           = "test2"
    frontend_ip_configuration_name = "ip_config_2"
    frontend_port_name             = "front_end_port_2"
    protocol                       = "Https"
    port                           = 80
  }

  # Required
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

    protocol = "Https"

    path = "test-path"
    timeout = 100
    unhealthy_threshold = 2
  }

  # Policy type needs to be custom to check cipher_suites
  ssl_policy {
    policy_type = "Custom"
    
    cipher_suites = []

    min_protocol_version = "TLSv1_2"
    disabled_protocols = []
  }

  ssl_certificate {
    name = "test-cert"
    key_vault_secret_id = ""
    password = "test-cert-pass"
  }
}
