variable "resource_group" {
    type = string
    default = "foo"
    description = "Name of the resource group"  
}

variable "resource_location" {
    type = string
    default = "West Europe"
    description = "Location of the resource group"
}

resource "azurerm_resource_group" "foo" {
  name     = var.resource_group
  location = var.resource_location
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault_foo" {
  name                              = "foo-keyvault"
  location                          = azurerm_resource_group.foo.location
  resource_group_name               = azurerm_resource_group.foo.name
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  sku_name                          = "premium"
  enabled_for_disk_encryption       = true
  purge_protection_enabled          = true
  enabled_for_template_deployment   = true
  enable_rbac_authorization         = false

  soft_delete_retention_days        = 7
  enabled_for_deployment            = true

  network_acls {
    bypass          = ""             // Possible values are AzureServices and None.
    default_action  =  ""          // When no rules match from ip_rules/virtual_network_subnet_ids
    ip_rules        =   ""
    virtual_network_subnet_ids   = ""
  }

  contact {
    email  =  "foo@example.com"
    name   = "foo"
    phone  =  ""
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    azure_ad_user_principal_names       = ["foo1@example.com", "foo2@example.com"]
    key_permissions                     = ["all"]
    secret_permissions                  = ["all"]
    certificate_permissions             = "["Get"]"
  }
}

// Needed for Encrypted disk
resource "azurerm_key_vault_key" "foo_key" {
  name              = "foo-vault_key"
  key_vault_id      = azurerm_key_vault.key_vault_foo.id
  key_type          = ""
  key_size          = 2048
  curve = ""
  expiration_date = ""
  not_before_date = ""
  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

resource "azurerm_key_vault_secret" "foo_secret" {
  name = "foo-vault_secret"
  key_vault_id = azurerm_key_vault.key_vault_foo.id
}

resource "azurerm_key_vault_certificate" "foo" {
  name              = "generated-cert"
  key_vault_id      = azurerm_key_vault.key_vault_foo.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["foo.com", "www.foo.com"]
      }

      subject            = "CN=foo"
      validity_in_months = 12
    }
  }
}