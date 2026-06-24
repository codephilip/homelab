# VMs that live on prox-1 (the anchor host).
# The resource block is identical to the other prox-N.tf files; only the
# host filter, provider alias, and node_name differ. We keep them in
# separate files because each host has its own provider alias and the
# bpg/proxmox provider doesn't allow dynamic provider selection.

locals {
  prox1_vms = { for k, v in local.vms : k => v if v.host == "prox1" }
}

resource "proxmox_virtual_environment_vm" "prox1" {
  provider = proxmox.prox1
  for_each = local.prox1_vms

  name        = each.key
  description = "Managed by terraform · ${each.key}"
  node_name   = "prox-1"
  vm_id       = tonumber(split(".", each.value.ip)[3])

  clone {
    vm_id = local.template_vmid
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  initialization {
    user_account {
      username = "ubuntu"
      keys     = [trimspace(var.ssh_public_key)]
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${local.network.netmask}"
        gateway = local.network.gateway
      }
    }
  }
}
