resource "azurerm_resource_group" "aks_example" {
  name     = "example-resources"
  location = "West Europe"
}
# managed cluster in protos
resource "azurerm_kubernetes_cluster" "example" {
  # oak9: azurerm_kubernetes_cluster.kubernetes_version is not configured
  # oak9: azurerm_kubernetes_cluster.network_profile.network_policy is not configured
  # All options # Must be configured
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  # SaC Testing - Severity: Critical - Set disk_encryption_set_id to ""
  disk_encryption_set_id = ""

  # SaC Testing - Severity: High - Set private_cluster_enabled to false
  private_cluster_enabled = false

  load_balancer_profile{
      # SaC Testing - Severity: High - Set idle_timeout_in_minutes to > 5
      idle_timeout_in_minutes = 10
  }
  
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id = "example-id"
    
    # SaC Testing - Severity: Critical - Set client_secret to ""
    client_secret = ""
  }

  network_profile {
    network_plugin = "none"
    load_balancer_sku = "standard"
    load_balancer_profile {
      # SaC Testing - Severity: Critical - Set outbound_ip_address_ids to []
      outbound_ip_address_ids = []
    }

  }

  azure_active_directory_role_based_access_control {
    managed = true
    # SaC Testing - Severity: Critical - Set azure_rbac_enabled to false
    azure_rbac_enabled = false
  }
  tags = {
    Environment = "Production"
  }
}

# managed cluster agent pools in protos
resource "azurerm_kubernetes_cluster_node_pool" "example" {
  # oak9: microsoft_container_service.managed_clusters_agent_pools[0].orchestrator_version is not configured
  # oak9: microsoft_container_service.managed_clusters_agent_pools[0].os_type is not configured
  # All options # Must be configured
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_DS2_v2"

  # SaC Testing - Severity: Critical - Set enable_node_public_ip to true
  enable_node_public_ip = true

  # SaC Testing - Severity: High - Set zones to []
  zones = []

  # SaC Testing - Severity: High - Set enable_auto_scaling to false
  enable_auto_scaling = false

  max_count = 100
  min_count = 0

  tags = {
    Environment = "Production"
  }
}