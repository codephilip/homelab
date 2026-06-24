#!/usr/bin/env bash
# Build the Ubuntu 24.04 cloud-init template (VM ID 9000) on a Proxmox host.
#
# Usage:   scripts/build-template.sh prox-1
# Then:    repeat for prox-2 and prox-3.
#
# Idempotent — safe to re-run; will skip if VM 9000 already exists.

set -euo pipefail

HOST="${1:-}"
if [[ -z "$HOST" ]]; then
  echo "Usage: $0 <prox-1|prox-2|prox-3>" >&2
  exit 1
fi

IMG="noble-server-cloudimg-amd64.img"
URL="https://cloud-images.ubuntu.com/noble/current/${IMG}"
VMID=9000

ssh "root@${HOST}" bash -s <<EOF
set -euo pipefail

if qm status ${VMID} >/dev/null 2>&1; then
  echo "VM ${VMID} already exists on \$(hostname); skipping."
  exit 0
fi

cd /var/lib/vz/template/iso

if [[ ! -f "${IMG}" ]]; then
  wget -q --show-progress "${URL}"
fi

apt-get update >/dev/null
apt-get -y install libguestfs-tools >/dev/null
virt-customize -a "${IMG}" --install qemu-guest-agent
virt-customize -a "${IMG}" --run-command 'systemctl enable qemu-guest-agent'

qm create ${VMID} --name ubuntu-2404-tmpl --memory 2048 --cores 2 \\
  --net0 virtio,bridge=vmbr0 --ostype l26 --agent enabled=1
qm importdisk ${VMID} "${IMG}" local-lvm
qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-${VMID}-disk-0
qm set ${VMID} --boot c --bootdisk scsi0
qm set ${VMID} --ide2 local-lvm:cloudinit
qm set ${VMID} --serial0 socket --vga serial0
qm template ${VMID}

echo "Template ${VMID} created on \$(hostname)."
EOF
