resource_group_name     = ""
public_ssh_key          = ""
cluster_name            = ""
kubernetes_version      = ""
node_resource_group     = ""
dns_prefix              = "TestAKS"
sku_tier                = "Free"
private_cluster_enabled = false
admin_username          = "azureuser"
#orchestrator_version
name                  = ""
node_count            = 1
vm_size               = "Standard_D2s_v3"
os_disk_size_gb       = 50
vnet_subnet_id        = ""
enable_auto_scaling   = false
max_count             = 1
min_count             = 1
enable_node_public_ip = false
availability_zones    = var.agents_availability_zones
node_labels = {
  "node1" : "label1"
}
type = "VirtualMachineScaleSets"
#max_pods               = var.agents_max_pods
enable_host_encryption = false
identity_type ="UserAssigned"
network_plugin     = "azure"
network_policy     = "azure"
    #dns_service_ip     = var.net_profile_dns_service_ip
#docker_bridge_cidr = var.net_profile_docker_bridge_cidr
// outbound_type      = var.net_profile_outbound_type
// pod_cidr           = var.net_profile_pod_cidr
// service_cidr       = var.net_profile_service_cidr