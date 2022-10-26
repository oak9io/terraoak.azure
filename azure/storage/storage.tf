resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  # oak9: microsoft_storage.storage_accounts.network_acls.virtual_network_rules is not configured
  # oak9: azurerm_key_vault.network_acls.bypass is not configured
  # oak9: azurerm_key_vault.network_acls.default_action is not set to deny by default
  # oak9: microsoft_storage.storage_accounts.encryption.keyvaultproperties is not configured
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # SaC Testing - Severity: Criticial - Set min_tls_version to TLS_1_0
  min_tls_version = "TLS_1_0"

  # SaC Testing - Severity: High - allow_nested_items_to_be_public true
  allow_nested_items_to_be_public = true

  # SaC Testing - Severity: High - set public_network_access_enabled to true
  public_network_access_enabled = true

  blob_properties {
    
    cors_rule {
      
      # SaC Testing - Severity: High - Set allowed_headers to  ""
      allowed_headers = [""]
      
      # SaC Testing - Severity: High - Set allowed_methods to ""
      allowed_methods = ["get", "head", "post", "delete"]
      
      # SaC Testing - Severity: High - Set allowed_origins to *
      allowed_origins = ["*"]
      
      # SaC Testing - Severity: High - Set exposed_headers to ""
      exposed_headers = [""]

      # SaC Testing - Severity: High - Set max_age_in_seconds  to ""
      max_age_in_seconds = 86404
    }    
  }

  # SaC Testing - Severity: Critical - Set enable_https_traffic_only == false
  enable_https_traffic_only = false

  identity {
    # SaC Testing - Severity: Critical - Set type to ""
    type = ""
  }
  # SaC Testing - Severity: Critical - Set network_rules == undefined
  network_rules {
    # SaC Testing - Severity: High - Set default_action == ""
    default_action = ""
    # SaC Testing - Severity: High - Set bypasss == ""
    bypass = [""]
    # SaC Testing - Severity: Critical - Set ip_rules == ""
    ip_rules =  [""]
  # oak9: azurerm_storage_account.network_rules.ip_rules is not configured

    # Note: blueprint checks for ip_rule value and action which are both 
    # undefined in tf

    # Note: blueprint checks for network_rules state and id which are both
    # undefined in tf
  }

  tags = {
    environment = "staging"
  }

}

  # SaC Testing - Severity: High - Set keyvault to undefined
resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_id       = azurerm_key_vault.example.id

  # SaC Testing - Severity: High - Set key_name == ""
  key_name                    = ""
  # SaC Testing - Severity: High - Set key_name == ""
  key_version                 = ""
  # SaC Testing - Severity: High - Set user_assigned_identtity_id == ""
  user_assigned_identity_id   = ""

  # Note: all of these checks depend upon key_source = microsoft.keyvault
  # which is not defined in tf and can not be checked
}

resource "azurerm_storage_encryption_scope" "example" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.example.id
  source             = "Microsoft.KeyVault"
}