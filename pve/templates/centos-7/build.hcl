locals {
	template = local.workspace.packer.centos.7
}

source "proxmox" "centos" {
	proxmox_url =  "${local.workspace.proxmox.nodes.pve.auth.api_url}/api2/json"
	insecure_skip_tls_verify = local.workspace.proxmox.nodes.pve.auth.tls_insecure
	username = local.workspace.proxmox.nodes.pve.auth.username
	password = local.workspace.proxmox.nodes.pve.auth.password
	node = local.workspace.proxmox.nodes.pve.name
	
	vm_name = local.template.name
	vm_id = local.template.id
	
	memory = local.template.memory
	sockets = local.template.sockets
	cores = local.template.cores
	os = local.template.os

	network_adapters {
		model = "virtio"
		bridge = "vmbr0"
	}

	qemu_agent = true
	scsi_controller = local.template.scsi_controller

	disks {
		type = local.template.disk[0].type
		disk_size = local.template.disk[0].disk_size
		storage_pool = local.template.disk[0].storage_pool
		storage_pool_type = local.template.disk[0].storage_pool_type
		format = local.template.disk[0].format
	}

	ssh_username = local.workspace.default_user.name
	ssh_password = local.workspace.default_user.password
	ssh_timeout= "30m"
	
	iso_file = local.template.iso_file
	
	template_name = local.template.name
	template_description = local.template.description
	unmount_iso = true
   
	http_directory = "./templates/centos-7/http"
	boot_wait= "20s"
	boot_command = [
		"<esc><wait><wait><wait><wait><wait>",
		"linux ks=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg",
		" USERNAME=${local.workspace.default_user.name}",
		" PASSWORD=${local.workspace.default_user.password}",
		" TIME_ZONE=${local.template.time_zone}",
		" network --device=eth0 --bootproto=dhcp --onboot=yes --activate",
		"<wait><wait><wait><enter>"
	]
}

build {
	sources = [
		"source.proxmox.centos"
	]

	provisioner "shell" {
		# only = ["centos"] # <- not supported yet https://github.com/hashicorp/packer/issues/9094
		inline = [
			"sleep 30",
			"sudo yum -y install cloud-init",
			"exit 0",
		]
	}
}