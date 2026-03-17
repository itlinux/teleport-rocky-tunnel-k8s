resource "null_resource" "teleport_token" {
  triggers = {
    vm_count = var.vm_count
  }

  provisioner "local-exec" {
    command = "ssh root@${var.teleport_auth_host} 'tctl tokens add --type=node,kube --ttl=2h --format=text' > /tmp/teleport_token.txt"
  }
}

data "local_file" "teleport_token" {
  depends_on = [null_resource.teleport_token]
  filename   = "/tmp/teleport_token.txt"
}
