resource "libvirt_network" "bridge" {
  name   = var.bridge_name
  mode   = "bridge"
  bridge = "bond-br"
  dhcp {
    enabled = false
  }
}

resource "libvirt_cloudinit_disk" "cf_cloud_init" {
  count     = var.vm_count
  name      = format("cf_cloud_init%02d", count.index)
  pool      = "images"
  user_data = <<EOF
#cloud-config
hostname: ${format("${var.vm-name}-%02d", count.index)}
fqdn: ${format("${var.vm-name}-%02d.local", count.index)}
yum_repos:
  epel-testing:
    baseurl: https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/
    enabled: true
    failovermethod: priority
    gpgcheck: false
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9-Testing
    name: Extra Packages for Enterprise Linux 9 - Testing
  kubernetes:
    name: Kubernetes
    baseurl: https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
    enabled: true
    gpgcheck: true
    gpgkey: https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
packages:
  - ca-certificates
  - curl
  - gnupg
growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false
users:
  - name: remo
    passwd: ${htpasswd_password.hash.sha512}
    lock_passwd: false
    ssh-authorized-keys:
      - ${jsonencode(trimspace(file(var.public_key_file_path)))}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_import_id:
      - gh:${var.username}
  - name: root
    ssh-authorized-keys:
      - ${jsonencode(trimspace(file(var.public_key_file_path)))}
ssh_pwauth: True
chpasswd:
  list: |
    root:${var.rootpass}
  expire: False
write_files:
  - path: /etc/teleport.yaml
    content: |
      version: v3
      teleport:
        nodename: ${format("${var.vm-name}-%02d", count.index)}
        data_dir: /var/lib/teleport
        join_params:
          token_name: "${trimspace(data.local_file.teleport_token.content)}"
          method: token
        ca_pin: "${var.teleport_ca_pin}"
        proxy_server: ${var.teleport_proxy}:443
        log:
          output: stderr
          severity: INFO
          format:
            output: text
      auth_service:
        enabled: "no"
      proxy_service:
        enabled: "no"
      ssh_service:
        enabled: "yes"
        labels:
          env: ${var.teleport_env_label}
          role: k3s
      kubernetes_service:
        enabled: "yes"
        kubeconfig_file: /root/.kube/config
runcmd:
  - echo "${var.teleport_auth_ip}  ${var.teleport_proxy}" >> /etc/hosts
  - ip a s eth0|grep inet| awk '{print $2}' |tee /etc/issue
  - dnf install -y cloud-utils-growpart gdisk libicu git wget net-tools httpd-tools htop epel-release kubectl
  - dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  - dnf install -y docker-ce docker-ce-cli containerd.io
  - systemctl enable --now docker
  - usermod -aG docker remo
  - echo ${var.docker_login_token} >/tmp/docker_token
  - cat /tmp/docker_token |docker login --username itlinux --password-stdin
  - wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  - modprobe ip_tables
  - echo 'ip_tables'| tee -a /etc/modules
  - k3d cluster create myk3scluster
  - mkdir -p /root/.kube/
  - sleep 15; k3d kubeconfig get myk3scluster |tee /root/.kube/config
  - dnf install -y 'https://cdn.teleport.dev/teleport-${var.teleport_version}-1.x86_64.rpm'
  - systemctl enable teleport --now
EOF
}

resource "libvirt_volume" "rocky_base" {
  name   = var.libvirt_volume_name
  source = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  pool   = "images"
}

resource "libvirt_volume" "rocky_instance" {
  count          = var.vm_count
  name           = format("rocky-instance-%02d", count.index)
  base_volume_id = libvirt_volume.rocky_base.id
  size           = var.disksize
  pool           = "images"
}

resource "libvirt_domain" "rocky_instance" {
  count  = var.vm_count
  name   = format("${var.vm-name}-%02d", count.index)
  memory = 4096
  vcpu   = 2

  network_interface {
    network_name = libvirt_network.bridge.name
  }

  cloudinit = libvirt_cloudinit_disk.cf_cloud_init[count.index].id

  disk {
    volume_id = libvirt_volume.rocky_instance[count.index].id
  }

  cpu {
    mode = "host-passthrough"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
