resource "azurerm_resource_group" "aks_example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "example" {
  # All options # Must be configured
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  disk_encryption_set_id = azurerm_disk_encryption_set.example.id

  private_cluster_enabled = false

  load_balancer_profile{
      
      idle_timeout_in_minutes = 10
  }
  
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id = "example-id"
    
    
    client_secret = "SecretText"
  }

  network_profile {
    network_plugin = "none"
    load_balancer_sku = "standard"
    load_balancer_profile {
      
      outbound_ip_address_ids = []
    }

  }

  azure_active_directory_role_based_access_control {
    managed = true
    
    azure_rbac_enabled = true
  }
  tags = {
    Environment = "Production"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "example" {
  # All options # Must be configured
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_DS2_v2"

 
  enable_node_public_ip = false

  
  zones = []

  enable_auto_scaling = false

  max_count = 100
  min_count = 0

  tags = {
    Environment = "Production"
  }
}