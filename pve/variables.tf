#############################################################
# Proxmox API variables
#############################################################
variable "proxmox_api_url" {
  description = "Proxmox api url"
  type        = string
  validation {
    condition     = can(regex("^http", var.proxmox_api_url))
    error_message = "Must be an URL, e.g. https://192.168.1.1:8006."
  }
}

variable "proxmox_api_username" {
  description = "Proxmox api username"
  type        = string
}

variable "proxmox_api_password" {
  description = "Proxmox api password"
  type        = string
}

variable "proxmox_api_otp" {
  description = "Proxmox api OTP"
  type        = string
  default     = ""
}

variable "proxmox_api_tls_insecure" {
  description = "Allow insecure connection to Proxmox API"
  type        = bool
  default     = true
}

#############################################################
# Proxmox Cluster Settings
#############################################################
variable "default_pool_id" {
  description = "Default Pool that will be created in the cluster"
  type        = string
  default     = "pve"
}

#############################################################
# Proxmox Node variables
#############################################################
variable "default_time_zone" {
  description = "Time zone that will be used on Proxmox nodes"
  type        = string
  default     = "UTC"
}

variable "default_data_store_id" {
  description = "Data store for VZDump backup file, ISO image, Container template, Snippets"
  type        = string
  default     = "local"
}

variable "default_vm_store_id" {
  description = "Data store for that supports Disk image and Containers (e.g. storage with type LVM-Thin)"
  type        = string
  default     = "local-lvm"
}

#############################################################
# Proxmox Domain Settings
#############################################################
variable "domain_name" {
  description = "Domain name"
  type = string
}

variable "dns_servers" {
  description = "List of external DNS Servers"
  type = list(string)
  default = [
    "1.1.1.1",
    "8.8.8.8",
  ]
}

#############################################################
# Cloudflare API variables
#############################################################
variable "cloudflare_account_email" {
  description = "Cloudflare account email"
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  default     = ""
}

#############################################################
# Default user settings
#############################################################
variable "user_name" {
  description = "Default username"
  type        = string
  default     = "deploy"
}

variable "user_password" {
  description = "Default password"
  type        = string
}

variable "user_ssh_public_key_location" {
  description = "SSH public key location path"
  type        = string
  default      = "~/.ssh/id_rsa.pub"
}

variable "user_email" {
  description = "Default administrators's email"
  type = string
}

#############################################################
# Packer variables
#############################################################
variable "packer_default_cores" {
  description = "Amount of CPU cores that will be allocated to a VM"
  type = number
  default = 2
}

#############################################################
# Kubernetes Cluster variables
#############################################################
variable "k8s_vm_provisioner_user_public_keys" {
  description = "SSH public keys that will be added to each node in the cluster"
  default = []
  type = list(string)
}

variable "k8s_vm_dns" {
  description = "DNS server that will be used by the virtual machines (e.g 192.168.1.1)"
  type = string
}

#############################################################
# Kubernetes Cluster  - HAProxy load balancer variables
#############################################################
variable "k8s_vm_haproxy_count" {
  description = "Number of VMs for Haproxy"
  type        = number
  default     = 0
}

variable "k8s_vm_haproxy_vip" {
  description = "IP address that will be used by keepalived (e.g 192.168.1.2)"
  type = string
}

variable "k8s_vm_haproxy_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_haproxy_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_haproxy_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_haproxy_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_haproxy_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_haproxy_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Cluster  - Master Node variables
#############################################################
variable "k8s_vm_master_count" {
  description = "Number of Master Nodes"
  type        = number
  default     = 3
}

variable "k8s_vm_master_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_master_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_master_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_master_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_master_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_master_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Cluster  - Worker Node variables
#############################################################
variable "k8s_vm_worker_count" {
  description = "Number of Worker Nodes"
  type        = number
  default     = 3
}

variable "k8s_vm_worker_clone_id" {
  description = "VM template id to clone from"
  type = number
}

variable "k8s_vm_worker_cpu_cores" {
  description = "Number of CPU cores"
  type = number
  default = 2
}

variable "k8s_vm_worker_cpu_sockets" {
  description = "Number of CPU sockets"
  type = number
  default = 1
}

variable "k8s_vm_worker_ram_dedicated" {
  description = "Amount of dedicated RAM"
  type = number
  default = 2048
}

variable "k8s_vm_worker_ram_floating" {
  description = "Amount of floating RAM"
  type = number
  default = 1536
}

variable "k8s_vm_worker_proxmox_datastore_id" {
  description = "Where on Proxmox VM should be stored (datastore id)"
  type = string
  default = "local-lvm"
}

#############################################################
# Kubernetes Infrastructure variables
#############################################################
variable "k8s_metallb_ip_range" {
  # Reference: https://metallb.universe.tf/configuration/
  description = "IP range that will be used by Metallb"
  type = string
}

# Storage
# NFS Server
variable "k8s_nfs_default_storage_class" {
  type = bool
  description = "Enables NFS Server as default Storage Class provisioner"
  default = false
}

variable "k8s_nfs_server_address" {
  type = string
  description = "NFS server IP/Name"
  default = ""
}

# Gluster Server
variable "k8s_gluster_cluster_endpoints" {
  type = list(string)
  default = []
  description = "List of Gluster cluster endpoints"
}


#############################################################
# Bastion Host variables
#############################################################
variable "digital_ocean_api_key" {
  description = "Digital Ocean API key"
  default = ""
  type = string
}

variable "bastion_user_name" {
  description = "Bastion host default username"
  type        = string
  default     = "deploy"
}

variable "bastion_ssh_port" {
  description = "Set desired SSH access port. Provisioner will change default port (22) to specified below"
  type        = number
  default     = 45321
}

variable "bastion_ssh_public_key_location" {
  description = "SSH public key location path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_hostname" {
  description = "Droplet's Hostname"
  type        = string
  default     = "bastion"
}

variable "bastion_region" {
  description = "Digital Ocean region"
  type        = string
  default     = "nyc3"
}

variable "bastion_size" {
  description = "Digital Ocean droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "bastion_image" {
  description = "Digital Ocean OS image name"
  type        = string
  default     = "ubuntu-19-10-x64"
}

variable "bastion_service_frp_bind_port" {
  description = "FRP Proxy bind port"
  type        = number
  default     = 7000
}

variable "bastion_service_frp_token" {
  description = "FRP Proxy token"
  type        = string
  default     = ""
}

variable "bastion_service_frp_vhost_http_port" {
  description = "FRP Proxy virtual host port"
  type        = number
  default     = 8080
}

#############################################################
# Bastion Host - Container variables
#############################################################
variable "bastion_traefik_container_file_cfg_static" {
  description = "Traefik container's static file configuration"
  # Reference: https://docs.traefik.io/reference/static-configuration/file/
  type = any
  default = {}
}

variable "bastion_traefik_container_file_cfg_dynamic" {
  description = "Traefik container's file configuration"
  # Reference: https://docs.traefik.io/reference/dynamic-configuration/file/
  type = map(any)
  default = {}
}

variable "bastion_traefik_container_network_advanced" {
  description = "List of networks Traefik will be a part of"
  type = list(string)
  default = []
}

variable "bastion_traefik_container_basic_auth" {
  description = "List of basic authentication credentials for Traefik"
  # Can be generated using: htpasswd -nb <name> <password>
  type = list(string)
  default = []
}

variable "bastion_drone_server_rpc_secret" {
  description = "Drone Server RPC Secret (Any random string)"
  type = string
  default = ""
}

variable "bastion_drone_server_github_client_id" {
  description = "Github Client ID; Used by Drone Server for OAuth"
  type = string
  default = ""
}

variable "bastion_drone_server_github_client_secret" {
  description = "Github Client Secret; Used by Drone Server for OAuth"
  type = string
  default = ""
}

variable "bastion_drone_server_user_filter" {
  description = "Allowed users"
  type = string
  default = ""
}

variable "bastion_drone_server_user_admin" {
  description = "Create user Administrator"
  type = string
  default = ""
}

#############################################################
# Authentication variables
#############################################################
variable "github_oauth_client_id" {
  type = string
  description = "Github Oauth Client ID"
  default = ""
}

variable "github_oauth_client_secret" {
  type = string
  description = "Github Oauth Client Secret"
  default = ""
}

#############################################################
# K8s infrastructure variables
#############################################################
variable "deemix_arl" {
  type = string
  description = "Deemix ARL. Authentication string obtained from cookies"
  default = ""
}

variable "nordvpn_username" {
  type = string
  description = "NordVPN username"
  default = ""
}

variable "nordvpn_password" {
  type = string
  description = "NordVPN password"
  default = ""
}

variable "nordvpn_server" {
  type = string
  description = "NordVPN Server to connect (e.g. us5839)"
  default = ""
}

variable "mongodb_root_password" {
  type = string
  description = "Set MongoDB root password during first run"
  default = ""
}

variable "redis_password" {
  type = string
  description = "Set Redis password during first run"
  default = ""
}

variable "postgresql_password" {
  type = string
  description = "Set PostgreSQL password during first run"
  default = "postgresql"
}

variable "pgadmin_default_email" {
  type = string
  description = "pgAdmin default email"
  default = "example@domain.com"
}

variable "pgadmin_default_password" {
  type = string
  description = "pgAdmin default password"
  default = "pgadmin"
}

variable "ceph_admin_secret" {
  type = string
  description = "Ceph admin secret. To get the key: > ceph auth get-key client.admin"
  default = ""
}

variable "ceph_user_secret" {
  type = string
  # To create a user account: > ceph --cluster ceph auth get-or-create client.kube mon 'allow r' osd 'allow rwx pool=<pool_name>>'
  description = "Ceph user secret. To get user account key: > ceph --cluster ceph auth get-key client.kube"
  default = ""
}

variable "ceph_monitors" {
  type = string
  description = "Comma separated list of Ceph Monitors (e.g. 192.168.88.1:6789)"
  default = ""
}

variable "ceph_pool_name" {
  type = string
  description = "Ceph pool name that will be used by StorageClass"
  default = ""
}

variable "ceph_admin_id" {
  type = string
  description = "Ceph Admin ID"
  default = "admin"
}

variable "ceph_user_id" {
  type = string
  description = "Ceph User ID"
  default = "kube"
}