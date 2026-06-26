# IP & DNS Plan

> The pattern this repo uses for laying out hosts, VMs, and lab-internal
> DNS. The values below are **examples** — swap in your own subnet, host
> IPs, and hostnames. The rules and the shape are what matter.

## The rule

```
prox-N (the Proxmox host)          →  10.0.0.10N
VMs that live on prox-N            →  10.0.0.1N0–.1N9
```

So with three Proxmox hosts:

```
prox-1  →  10.0.0.101  ·  VMs in  10.0.0.110–.119
prox-2  →  10.0.0.102  ·  VMs in  10.0.0.120–.129
prox-3  →  10.0.0.103  ·  VMs in  10.0.0.130–.139
```

When you add a VM, you know exactly which range it belongs to. Removes a
class of "wait, which host is that on?" mistakes.

## Example layout (matches the rest of this repo)

| Hostname | IP | DNS shortcut(s) | What it is |
|---|---|---|---|
| gateway | 10.0.0.1 | `gw.lab` | Lab router |
| prox-1 | 10.0.0.101 | `prox-1.lab` | Proxmox host #1 (anchor) |
| prox-2 | 10.0.0.102 | `prox-2.lab` | Proxmox host #2 (workers + CI) |
| prox-3 | 10.0.0.103 | `prox-3.lab` | Proxmox host #3 (workers + ops) |
| k3s-cp1 | 10.0.0.110 | `k3s.lab` | k3s control plane |
| db1 | 10.0.0.111 | `db.lab`, `postgres.lab` | PostgreSQL |
| ts-router | 10.0.0.112 | `ts-router.lab` | Tailscale subnet router |
| backup1 | 10.0.0.113 | `backup.lab` | restic + cron backups |
| k3s-w1 | 10.0.0.120 | `k3s-w1.lab` | k3s worker (hosts Traefik) |
| ci1 | 10.0.0.121 | `ci.lab` | GitHub Actions runner |
| sandbox1 | 10.0.0.122 | `sandbox.lab` | Throwaway experiments |
| k3s-w2 | 10.0.0.130 | `k3s-w2.lab` | k3s worker |
| obs1 | 10.0.0.131 | `obs1.lab`, `grafana.lab`, `prometheus.lab`, `loki.lab` | Observability stack |
| util1 | 10.0.0.132 | `util1.lab`, `adguard.lab` | AdGuard Home (DNS) |
| Mac Mini | 10.0.10.50 | `macmini.lab`, `ollama.lab` | AI inference (separate VLAN) |

These specific numbers aren't load-bearing — only the *shape* is. Pick
any RFC1918 subnet you like; if you keep the `.10N` / `.1N0–.1N9` rule,
the rest of the repo just works.

## VLAN model

A typical UniFi-style segmentation:

| VLAN | Name | Subnet | Used for |
|---|---|---|---|
| 10 | LAN | varies | Personal devices — laptop, phone |
| 20 | SERVERS | 10.0.0.0/24 (example) | Proxmox hosts + lab VMs |
| 30 | IoT | 10.0.30.0/24 (example) | Lab-side IoT (isolated) |
| 40 | GUEST | 10.0.40.0/24 (example) | Visitors (internet only) |
| 60 | AI | 10.0.10.0/24 (example) | Mac Mini + future AI gear |

The AI VLAN is separate from SERVERS for two reasons: it lets the Mac
talk to LAN-side dev tools directly, and it keeps GPU-heavy traffic off
the server VLAN. If you don't care, collapse them into one.

## How names resolve

### From inside the SERVERS VLAN

Devices on VLAN 20 get the AdGuard host (`util1`, example: 10.0.0.132)
as their DNS server via DHCP from the gateway. AdGuard has rewrite rules
for every `.lab` shortcut — see `ansible/adguard-rewrites.yml`.

Verify from any lab VM:
```bash
dig +short prox-1.lab @10.0.0.132
# 10.0.0.101
```

### From your laptop on the LAN

1. **Gateway DHCP** hands out the AdGuard IP as DNS for your LAN VLAN.
2. **Tailscale split-DNS** in admin console: any `*.lab` query is routed
   to AdGuard through the tailnet tunnel.

If either layer doesn't deliver, the fallback is `/etc/hosts` on the
laptop.

### From anywhere via Tailscale

Once the Tailscale split-DNS rule is active, `.lab` resolves on your
laptop / phone / iPad from anywhere — the query goes through the tailnet
to AdGuard.

For machines that are themselves on the tailnet (the Proxmox hosts,
after `proxmox-tailscale.yml`), MagicDNS also gives you
`prox-N.<tailnet>.ts.net` URLs that resolve everywhere with no extra
setup.

## Adding a new VM — the 4 places to update

1. `terraform/locals.tf` — add to `local.vms` with host/IP/sizing
2. `ansible/inventory.yml` — add to the relevant group(s)
3. `ansible/adguard-rewrites.yml` — add the `.lab` shortcut entries
4. This file (if you keep it) — for your own reference

Then:
```bash
cd terraform && terraform apply
cd ../ansible && ansible-playbook adguard-rewrites.yml
```

## Out of scope (intentionally)

- **No real domains.** Public-internet hosts (the small handful you'd
  port-forward through your gateway for Traefik) use real domains from
  your registrar with Let's Encrypt certs via cert-manager. Those aren't
  in this doc — they belong wherever you keep your registrar records.
- **No Tailscale IPs.** `100.x.x.x` addresses change when a device
  re-auths. Use MagicDNS names (`prox-1.<tailnet>.ts.net`) instead.
