# VMs that live on prox-3 (workers + ops).

locals {
  prox3_vms = { for k, v in local.vms : k => v if v.host == "prox3" }
}

resource "proxmox_virtual_environment_vm" "prox3" {
  provider = proxmox.prox3
  for_each = local.prox3_vms

  name        = each.key
  description = "Managed by terraform · ${each.key}"
  node_name   = "prox-3"
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
