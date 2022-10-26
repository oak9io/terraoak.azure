resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version = "TLS_1_0"

  allow_nested_items_to_be_public = true

  public_network_access_enabled = true

  blob_properties {
    
    cors_rule {
      
      allowed_headers = [""]
      
      allowed_methods = ["get", "head", "post", "delete"]
      
      allowed_origins = ["*"]
      
      exposed_headers = [""]

      max_age_in_seconds = 86404
    }    
  }

  enable_https_traffic_only = true

  identity {

    type = "SystemAssigned"
  }
  network_rules {
    default_action = "deny"
    bypass = ["None"]
    ip_rules =  ["10.0.0.1"]
    virtual_network_rules = [azurerm_virtual_network.example.id]
   
  }

  tags = {
    environment = "staging"
  }

}

resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_id       = azurerm_key_vault.example.id

  key_name                    = ""
  key_version                 = ""
  user_assigned_identity_id   = ""

  
}

resource "azurerm_storage_encryption_scope" "example" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.example.id
  source             = "Microsoft.KeyVault"
}