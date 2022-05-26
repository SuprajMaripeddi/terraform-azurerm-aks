data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "ssh-key" {
  source         = "./modules/ssh-key"
  public_ssh_key = var.public_ssh_key == "" ? "" : var.public_ssh_key
}


resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  name = "aksuser"
}
resource "azurerm_kubernetes_cluster" "main" {
  name                    = var.cluster_name == null ? "${var.prefix}-aks" : var.cluster_name
  kubernetes_version      = var.kubernetes_version
  location                = data.azurerm_resource_group.main.location
  resource_group_name     = data.azurerm_resource_group.main.name
  node_resource_group     = var.node_resource_group
  dns_prefix              = var.prefix
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(var.public_ssh_key == "" ? module.ssh-key.public_ssh_key : var.public_ssh_key, "\n", "")
    }
  }

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? [] : ["default_node_pool_manually_scaled"]
    content {
      orchestrator_version   = var.orchestrator_version
      name                   = var.agents_pool_name
      node_count             = var.agents_count
      vm_size                = var.agents_size
      os_disk_size_gb        = var.os_disk_size_gb
      vnet_subnet_id         = var.vnet_subnet_id
      enable_auto_scaling    = var.enable_auto_scaling
      max_count              = null
      min_count              = null
      enable_node_public_ip  = var.enable_node_public_ip
      availability_zones     = var.agents_availability_zones
      node_labels            = var.agents_labels
      type                   = var.agents_type
      tags                   = merge(var.tags, var.agents_tags)
      max_pods               = var.agents_max_pods
      enable_host_encryption = var.enable_host_encryption
    }
  }
  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []
    content {
      type                      = var.identity_type
      user_assigned_identity_id = azurerm_user_assigned_identity.main.id
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.net_profile_pod_cidr
    service_cidr       = var.net_profile_service_cidr
  }
  tags = var.tags
}


// resource "azurerm_log_analytics_workspace" "main" {
//   count               = var.enable_log_analytics_workspace ? 1 : 0
//   name                = var.cluster_log_analytics_workspace_name == null ? "${var.prefix}-workspace" : var.cluster_log_analytics_workspace_name
//   location            = data.azurerm_resource_group.main.location
//   resource_group_name = var.resource_group_name
//   sku                 = var.log_analytics_workspace_sku
//   retention_in_days   = var.log_retention_in_days

//   tags = var.tags
// }

// resource "azurerm_log_analytics_solution" "main" {
//   count                 = var.enable_log_analytics_workspace ? 1 : 0
//   solution_name         = "ContainerInsights"
//   location              = data.azurerm_resource_group.main.location
//   resource_group_name   = var.resource_group_name
//   workspace_resource_id = azurerm_log_analytics_workspace.main[0].id
//   workspace_name        = azurerm_log_analytics_workspace.main[0].name

//   plan {
//     publisher = "Microsoft"
//     product   = "OMSGallery/ContainerInsights"
//   }

//   tags = var.tags
// }


