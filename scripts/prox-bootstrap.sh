#!/usr/bin/env bash
# One-time bootstrap for a fresh Proxmox VE host.
#
# - Disables the enterprise (paid-subscription) PVE + Ceph repos
# - Enables the no-subscription PVE repo
# - Runs apt-get update so the rest of our scripts work
#
# Idempotent — safe to re-run.
#
# Usage: scripts/prox-bootstrap.sh prox-1
#        scripts/prox-bootstrap.sh prox-2
#        scripts/prox-bootstrap.sh prox-3

set -euo pipefail

HOST="${1:-}"
if [[ -z "$HOST" ]]; then
  echo "Usage: $0 <prox-1|prox-2|prox-3>" >&2
  exit 1
fi

ssh "root@${HOST}" bash -s <<'EOF'
set -euo pipefail

# Detect Debian codename (trixie for PVE 9, bookworm for PVE 8)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
echo "Detected Debian codename: ${CODENAME}"

# 1. Comment out enterprise repos in both old (.list) and new (.sources) formats.
for f in /etc/apt/sources.list.d/pve-enterprise.list \
         /etc/apt/sources.list.d/ceph.list; do
  if [[ -f "$f" ]]; then
    sed -i 's/^deb /# disabled by homelab bootstrap: deb /' "$f"
    echo "Disabled: $f"
  fi
done

for f in /etc/apt/sources.list.d/pve-enterprise.sources \
         /etc/apt/sources.list.d/ceph.sources; do
  if [[ -f "$f" ]]; then
    # In deb822 format, set Enabled: false (or add it if missing)
    if grep -q '^Enabled:' "$f"; then
      sed -i 's/^Enabled:.*/Enabled: false/' "$f"
    else
      echo "Enabled: false" >> "$f"
    fi
    echo "Disabled: $f"
  fi
done

# 2. Add the no-subscription repo (only if not already present)
NOSUB=/etc/apt/sources.list.d/pve-no-subscription.list
if [[ ! -f "$NOSUB" ]]; then
  echo "deb http://download.proxmox.com/debian/pve ${CODENAME} pve-no-subscription" > "$NOSUB"
  echo "Created: $NOSUB"
fi

# 3. Refresh apt cache
apt-get update

echo "✔ Bootstrap complete on $(hostname)."
EOF
