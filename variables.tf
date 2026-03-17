variable "docker_login_token" {}
variable "rootpass" {}

variable "username" {
  type    = string
  default = "remo"
}

variable "vm-name" {
  default = "teleport-demo"
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_count_worker" {
  type    = number
  default = 1
}

variable "public_key_file_path" {
  default = "/root/.ssh/id_rsa.pub"
}

variable "disksize" {
  type    = number
  default = "70866960384"
}

variable "disksize_worker" {
  type    = number
  default = "60866960384"
}

variable "vcpu_worker" {
  default = "2"
}

variable "mem_worker" {
  default = "4096"
}

variable "vm-name-worker" {
  default = "k8sw-teleport"
}

variable "bridge_name" {
  description = "CTL Bridge Name"
  default     = "teleport_kvm_clt_network"
}

variable "bridge_worker_name" {
  description = "Worker Bridge Name"
  default     = "kvm_worker_network"
}

variable "libvirt_volume_name" {
  description = "Libvirt Volume Name"
  default     = "libvirt_volume_teleport"
}

variable "libvirt_volume_w_name" {
  description = "Libvirt Worker Volume Name"
  default     = "libvirt_volume_w_teleport"
}

variable "teleport_auth_host" {
  description = "Internal hostname of Teleport auth server"
  default     = "teleport-server"
}

variable "teleport_proxy" {
  description = "Teleport proxy address (no port)"
  default     = "git.rm.ht"
}

variable "teleport_ca_pin" {
  description = "Teleport CA pin from tctl status"
}

variable "teleport_version" {
  description = "Teleport version to install"
  default     = "18.6.8"
}

variable "teleport_env_label" {
  description = "Environment label for Teleport node"
  default     = "homelab"
}

variable "teleport_auth_ip" {
  description = "Internal IP of Teleport auth server"
  default     = "192.168.1.152"
}
