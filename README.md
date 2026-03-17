# teleport-rocky-tunnel-k8s

Terraform project that provisions a Rocky Linux 9 VM on KVM/libvirt, deploys a k3d Kubernetes cluster, and automatically registers the node with a [Teleport](https://goteleport.com) cluster for SSH and Kubernetes access — no VPN required.

This project replaces a previous Cloudflare tunnel-based approach with Teleport's identity-aware proxy.

---

## Architecture

```
KVM Host (CentOS 7)
  └── Rocky Linux 9 VM (cloud-init)
        ├── Docker + k3d (k3s in Docker)
        ├── Teleport Node Agent (SSH)
        └── Teleport Kubernetes Agent → k3d-myk3scluster

Teleport Auth/Proxy (ftp-qmail)
  └── git.rm.ht:443 (Apache reverse proxy → Teleport :3080)
```

---

## Prerequisites

### KVM Host
- `libvirt` / `virsh` installed and running
- `terraform` >= 1.0
- SSH access to the Teleport auth server (`teleport-server` in `/etc/hosts`)
- `/etc/hosts` entry: `192.168.1.152  teleport-server`

### Teleport Auth Server
- Teleport 18.x running at `git.rm.ht`
- `tctl` available for token generation
- Apache reverse proxy configured for `git.rm.ht:443` → `127.0.0.1:3080`
- Internal IP: `192.168.1.152`

---

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/itlinux/teleport-rocky-tunnel-k8s.git
cd teleport-rocky-tunnel-k8s
```

### 2. Create a `terraform.tfvars` file

```hcl
docker_login_token = "your-docker-hub-token"
rootpass           = "your-root-password"
teleport_ca_pin    = "REDACTED"
```

### 3. Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

Terraform will:
1. SSH into `teleport-server` and generate a `node,kube` join token via `tctl`
2. Spin up a Rocky Linux 9 VM via cloud-init
3. Install Docker, k3d, and Teleport
4. Register the node with your Teleport cluster automatically

---

## Accessing Resources

### Via Teleport Web UI
Open `https://git.rm.ht` and connect to any node or Kubernetes cluster.

### Via tsh CLI

```bash
# Login
tsh login --proxy=git.rm.ht:443 --user=admin

# List nodes
tsh ls

# SSH into the VM
tsh ssh root@teleport-demo-00

# Access the k3s cluster
tsh kube login k3d-myk3scluster
kubectl get pods -A
```

---

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `vm-name` | VM hostname prefix | `teleport-demo` |
| `vm_count` | Number of VMs to create | `1` |
| `disksize` | Disk size in bytes (66GiB) | `70866960384` |
| `teleport_proxy` | Teleport proxy hostname | `git.rm.ht` |
| `teleport_auth_host` | Internal hostname of Teleport auth server | `teleport-server` |
| `teleport_auth_ip` | Internal IP of Teleport auth server | `192.168.1.152` |
| `teleport_ca_pin` | Teleport CA pin (`tctl status`) | `sha256:...` |
| `teleport_version` | Teleport version to install | `18.6.8` |
| `teleport_env_label` | Environment label for the node | `homelab` |
| `bridge_name` | KVM bridge network name | `teleport_kvm_clt_network` |
| `public_key_file_path` | Path to SSH public key | `/root/.ssh/id_rsa.pub` |
| `docker_login_token` | Docker Hub token | _(required)_ |
| `rootpass` | Root password for the VM | _(required)_ |

---

## Useful Commands

### Get Teleport CA pin
```bash
tctl status | grep CA
```

### List registered nodes
```bash
tctl nodes ls
tctl kube ls
```

### Remove a stale node
```bash
# Get UUID from the VM
cat /var/lib/teleport/host_uuid

# Remove stale node by UUID on the auth server
tctl rm node/<UUID>
```

### Generate a new join token manually
```bash
tctl tokens add --type=node,kube --ttl=2h --format=text
```

### Destroy the VM
```bash
terraform destroy
```

---

## Notes

- The Teleport join token is generated automatically via `local-exec` SSH and expires after 2 hours
- Once a node has joined the cluster, the token is no longer needed
- The `ca_pin` is stable for the lifetime of the cluster and only needs updating if the Teleport CA is rotated
- Rocky Linux 9 cloud image is downloaded automatically from the official Rocky Linux CDN
- k3d creates a single-node k3s cluster (`myk3scluster`) inside Docker
- The Teleport Kubernetes service auto-detects the kubeconfig at `/root/.kube/config`

---

## File Structure

```
.
├── provider.tf       # Terraform providers (libvirt, htpasswd)
├── rocky_ctl.tf      # VM, network, cloud-init, disk resources
├── teleport.tf       # Token generation + local_file data source
├── variables.tf      # All input variables
└── output.tf         # Password outputs
```
