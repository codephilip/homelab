# homelab

Declarative configuration for the lab network.

- **3× HP EliteDesk** running Proxmox VE (`prox-1`, `prox-2`, `prox-3` at `10.10.20.101-103`)
- **Mac Mini** standalone at `10.10.20.50`
- **k3s cluster** across Ubuntu VMs (1 control plane + 2 workers)
- **Tailscale** for remote access

## Layout

```
terraform/     VM lifecycle (bpg/proxmox provider)
ansible/       Configuration management (k3s, Postgres, AdGuard, etc.)
cloud-init/    First-boot user-data for new VMs
scripts/       One-off setup (template build, etc.)
```

## Usage

```bash
# One-time per Proxmox host (creates the cloud-init template)
scripts/build-template.sh prox-1

# Provision / update VMs
cd terraform && terraform apply

# Configure VMs (after they boot)
cd ansible && ansible-playbook site.yml
```

## Secrets

Never commit. Set via env vars in your shell (or `direnv`):

```
export TF_VAR_proxmox_api_token_prox1='terraform@pve!provisioner=<uuid>'
export TF_VAR_proxmox_api_token_prox2='terraform@pve!provisioner=<uuid>'
export TF_VAR_proxmox_api_token_prox3='terraform@pve!provisioner=<uuid>'
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
```
