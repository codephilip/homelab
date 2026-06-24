# Single source of truth for the IP plan.
# Rule: VMs on prox-N are in .1N0–.1N9.

locals {
  network = {
    gateway = "10.10.20.1"
    cidr    = "10.10.20.0/24"
    netmask = "24"
  }

  hosts = {
    prox1 = "10.10.20.101"
    prox2 = "10.10.20.102"
    prox3 = "10.10.20.103"
  }

  vms = {
    # Anchor (prox-1)
    k3s-cp1   = { host = "prox1", ip = "10.10.20.110", cores = 2, memory = 4096, disk = 32 }
    db1       = { host = "prox1", ip = "10.10.20.111", cores = 4, memory = 8192, disk = 100 }
    ts-router = { host = "prox1", ip = "10.10.20.112", cores = 1, memory = 1024, disk = 16 }
    backup1   = { host = "prox1", ip = "10.10.20.113", cores = 2, memory = 2048, disk = 200 }

    # Workers + CI (prox-2)
    k3s-w1   = { host = "prox2", ip = "10.10.20.120", cores = 4, memory = 10240, disk = 64 }
    ci1      = { host = "prox2", ip = "10.10.20.121", cores = 4, memory = 6144, disk = 120 }
    sandbox1 = { host = "prox2", ip = "10.10.20.122", cores = 2, memory = 4096, disk = 40 }

    # Workers + Ops (prox-3)
    k3s-w2 = { host = "prox3", ip = "10.10.20.130", cores = 4, memory = 10240, disk = 64 }
    obs1   = { host = "prox3", ip = "10.10.20.131", cores = 2, memory = 6144, disk = 80 }
    util1  = { host = "prox3", ip = "10.10.20.132", cores = 2, memory = 2048, disk = 40 }
  }

  # Template VM ID (built once per host by scripts/build-template.sh)
  template_vmid = 9000
}
