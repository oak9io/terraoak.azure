
resource "azurerm_application_gateway" "randy_gateway" {
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
    # SaC Testing - Severity: Critical - Set protocol != https
    protocol              = "http"

    # SaC Testing - Severity: Critical - Set authentication_certificate to undefined
    authentication_certificate {
    }

    # SaC Testing - Severity: High - Set trusted_root_certificate to undefined
    trusted_root_certificate {
    }
    request_timeout       = 60
  }

  # Required
  http_listener {
    name                           = "test1"
    frontend_ip_configuration_name = "ip_config_1"
    frontend_port_name             = "front_end_port_1"
    # SaC Testing - Severity: Critical - Set protocol to http
    protocol                       = "HTTP"
    port                           = 443
  }

  http_listener {
    name                           = "test2"
    frontend_ip_configuration_name = "ip_config_2"
    frontend_port_name             = "front_end_port_2"
    # SaC Testing - Severity: Critical - Set protocol to http
    protocol                       = "HTTP"
    port                           = 445
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

    # SaC Testing - Severity: Critical - Set protocol != https
    protocol = "http"

    path = "test-path"
    timeout = 100
    unhealthy_threshold = 2
  }

  # Policy type needs to be custom to check cipher_suites
  ssl_policy {
    policy_type = "Custom"
    
    # SaC Testing - Severity: Critical - Set cipher_suites != preferred value
    cipher_suites = []

    # SaC Testing - Severity: Critical - Set min_protocol_version !=  tlsv1_2
    min_protocol_version = "TLSv1_2"
    # SaC Testing - Severity: Critical - Set disabled_protocols to ""
    disabled_protocols = []
  }

  ssl_certificate {
    name = "test-cert"
    # SaC Testing - Severity: High - Set key_vault_secret_id to " "
    key_vault_secret_id = ""
    password = "test-cert-pass"
  }
}
