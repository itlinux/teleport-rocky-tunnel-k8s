variable docker_login_token {}
variable rootpass {}
variable username {
  type = string
  default = "remo"
}
variable vm-name {
 default = "cloudflare-demo"
}
variable vm_count {
  type = number
  default = 1
}
variable vm_count_worker {
  type = number
  default = 1
}

#variable sysdig_api_token {}
variable public_key_file_path {
  default = "/root/.ssh/id_rsa.pub"
}
variable phone_home_url {
  type    = string
  default = ""
}

variable disksize {
  type = number
  default = "70866960384" 
}
variable disksize_worker {
  type = number
  default = "60866960384" 
}
  # cal from terraform console = "66 * 1024 * 1024 * 1024" 
  # 66GiB. the root FS is automatically resized by cloud-init growpart (see https://cloudinit.readthedocs.io/en/latest/topics/examples.html#grow-partitions).

variable vcpu_worker {
  default = "2"
}
variable mem_worker {
  default = "4096"
}

variable vm-name-worker-cf {
  default = "k8sw-cloudflare"
}

variable "cloudflare_api_token" {
   description = "API Token Cloudflare"
 }

variable "cloudflare_domain_name" {
    default = "remomattei"
 }
 
 variable "cloudflare_name" {
    description = "the name for the A record to add to your domain. In my case the domain is remomattei"
    default     = "cloudflare"
 }
 variable "cloudflare_ip_address" {
    description = "The ip you want to set up for your A record"
    default     = "16.14.17.16"
 }
variable "proxied" {
    description = "false it setting it for passing. If this is enabled it will hide the IP"
    default     = false
 }
variable "bridge_name" {
    description = "CTL Name"
    default     = "kvm_clt_network"
 }
variable "bridge_worker_name" {
    description = "CTL Name"
    default     = "kvm_worker_network"
 }
variable "libvirt_volume_name" {
    description = "Libvirt Volume Name"
    default     = "libvirt_volume_cloudflare"
 }
variable "libvirt_volume_w_name" {
    description = "Libvirt Volume Name"
    default     = "libvirt_volume_w_cloudflare"
 }

variable "teleport_auth_host" {
  description = "Internal hostname of Teleport auth server"
  default     = "teleport-server"
}
