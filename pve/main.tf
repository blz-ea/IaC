locals {
  proxmox_nodes = {
    node1 = {
      name        = data.proxmox_virtual_environment_nodes.all_nodes.names[0]
      data_stores = data.proxmox_virtual_environment_datastores.node_1
    }
  }
}

#############################################################
# Proxmox Cluster Settings
#############################################################
# Get all available nodes
data "proxmox_virtual_environment_nodes" "all_nodes" {}

# Create default pool
resource "proxmox_virtual_environment_pool" "default_pool" {
  comment = "Managed by Terraform"
  pool_id = var.default_pool_id
}

#############################################################
# Proxmox Node 1 Settings
#############################################################
data "proxmox_virtual_environment_datastores" "node_1" {
  node_name = data.proxmox_virtual_environment_nodes.all_nodes.names[0]
}

# Set time Settings in Proxmox Virtual Environment
resource "proxmox_virtual_environment_time" "node_1" {
  node_name = local.proxmox_nodes.node1.name
  time_zone = var.default_time_zone
}

# Proxmox Node DNS settings
resource "proxmox_virtual_environment_dns" "node_1_dns_configuration" {
  domain    = var.domain_name
  node_name = local.proxmox_nodes.node1.name
  servers   = var.dns_servers # Limited to 3 server
}

#############################################################
# Kubernetes Cluster
#############################################################
module "proxmox_k8s_cluster" {
  providers = {
    proxmox = proxmox
  }

  vm_provisioner_user             = var.user_name
  vm_provisioner_user_password    = var.user_password
  vm_provisioner_user_public_keys = concat(
    [ trimspace(file(pathexpand(var.user_ssh_public_key_location)))],
    var.k8s_vm_provisioner_user_public_keys,
  )

  vm_dns                        = var.k8s_vm_dns

  # Haproxy nodes
  vm_haproxy_count              = var.k8s_vm_haproxy_count
  vm_haproxy_vip                = var.k8s_vm_haproxy_vip
  vm_haproxy_clone_id           = var.k8s_vm_haproxy_clone_id
  vm_haproxy_cpu_cores          = var.k8s_vm_haproxy_cpu_cores
  vm_haproxy_cpu_sockets        = var.k8s_vm_haproxy_cpu_sockets
  vm_haproxy_ram_dedicated      = var.k8s_vm_haproxy_ram_dedicated
  vm_haproxy_ram_floating       = var.k8s_vm_haproxy_ram_floating
  vm_haproxy_proxmox_node_name  = local.proxmox_nodes.node1.name
  vm_haproxy_proxmox_pool_id    = proxmox_virtual_environment_pool.default_pool.pool_id
  vm_haproxy_proxmox_datastore_id = var.k8s_vm_haproxy_proxmox_datastore_id

  # Master Nodes
  vm_master_count               = var.k8s_vm_master_count
  vm_master_clone_id            = var.k8s_vm_master_clone_id
  vm_master_cpu_cores 			= var.k8s_vm_master_cpu_cores
  vm_master_cpu_sockets         = var.k8s_vm_master_cpu_sockets
  vm_master_ram_dedicated       = var.k8s_vm_master_ram_dedicated
  vm_master_ram_floating        = var.k8s_vm_master_ram_floating
  vm_master_proxmox_node_name   = local.proxmox_nodes.node1.name
  vm_master_proxmox_pool_id     = proxmox_virtual_environment_pool.default_pool.pool_id
  vm_master_proxmox_datastore_id = var.k8s_vm_master_proxmox_datastore_id

  # Worker Nodes
  vm_worker_count               = var.k8s_vm_worker_count
  vm_worker_clone_id            = var.k8s_vm_worker_clone_id
  vm_worker_cpu_cores           = var.k8s_vm_worker_cpu_cores
  vm_worker_cpu_sockets         = var.k8s_vm_worker_cpu_sockets
  vm_worker_ram_dedicated       = var.k8s_vm_worker_ram_dedicated
  vm_worker_ram_floating        = var.k8s_vm_worker_ram_floating
  vm_worker_proxmox_node_name   = local.proxmox_nodes.node1.name
  vm_worker_proxmox_pool_id     = proxmox_virtual_environment_pool.default_pool.pool_id
  vm_worker_proxmox_datastore_id = var.k8s_vm_worker_proxmox_datastore_id

  dependencies = [
    null_resource.packer_ubuntu_bionic.id
  ]
  source = "./k8s_cluster"
}

#############################################################
# Kubernetes Infrastructure
#############################################################
module "proxmox_k8s_infrastructure" {
  domain_name               = var.domain_name
  metallb_ip_range          = var.k8s_metallb_ip_range
  cloudflare_api_token      = var.cloudflare_api_token
  cloudflare_account_email  = var.cloudflare_account_email
  cloudflare_zone_name      = var.domain_name
  nfs_server_address        = var.k8s_nfs_server_address

  k8s_config_file_path      = module.proxmox_k8s_cluster.k8s_config_file_path

  github_oauth_client_id    = var.github_oauth_client_id
  github_oauth_client_secret = var.github_oauth_client_secret
  user_email                = var.user_email
  default_time_zone         = var.default_time_zone
  dns_servers               = var.dns_servers

  // TODO: Find a better way to pass password related variables
  deemix_arl                = var.deemix_arl
  nordvpn_username          = var.nordvpn_username
  nordvpn_password          = var.nordvpn_password
  nordvpn_server            = var.nordvpn_server

  mongodb_root_password     = var.mongodb_root_password
  redis_password            = var.redis_password
  postgresql_password       = var.postgresql_password
  pgadmin_default_email     = var.pgadmin_default_email
  pgadmin_default_password  = var.pgadmin_default_password

  ceph_admin_secret         = var.ceph_admin_secret
  ceph_user_secret          = var.ceph_user_secret
  ceph_monitors             = var.ceph_monitors
  ceph_pool_name            = var.ceph_pool_name
  ceph_admin_id             = var.ceph_admin_id
  ceph_user_id              = var.ceph_user_id

  source = "./k8s_infrastructure"
}