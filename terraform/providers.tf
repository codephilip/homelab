# One provider alias per Proxmox host.
# The 3 hosts are standalone (not clustered), so each has its own API.
# Every resource must declare which host it lives on with `provider = proxmox.proxN`.

provider "proxmox" {
  alias     = "prox1"
  endpoint  = "https://10.10.20.101:8006/"
  api_token = var.proxmox_api_token_prox1
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

provider "proxmox" {
  alias     = "prox2"
  endpoint  = "https://10.10.20.102:8006/"
  api_token = var.proxmox_api_token_prox2
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

provider "proxmox" {
  alias     = "prox3"
  endpoint  = "https://10.10.20.103:8006/"
  api_token = var.proxmox_api_token_prox3
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}
