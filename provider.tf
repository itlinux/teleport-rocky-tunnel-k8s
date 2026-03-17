terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.4"
    }
  }
}

resource "random_string" "password" {
  length = 6
}

resource "htpasswd_password" "hash" {
  password = random_string.password.result
}
provider "libvirt" {
  uri = "qemu:///system"
}
