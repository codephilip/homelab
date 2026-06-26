# Open WebUI

Self-hosted ChatGPT-style frontend for the Mac mini's Ollama
(`10.0.10.50:11434` in the example inventory). Postgres-backed via the
shared `db1` instance.

## First-time setup

```bash
# 1. Set OPENWEBUI_DB_PASSWORD in .envrc, then:
ansible-playbook ansible/postgres.yml          # creates DB + openwebui-db Secret

# 2. Generate the session-signing secret (one-shot):
kubectl -n prod create secret generic openwebui-auth \
  --from-literal=WEBUI_SECRET_KEY="$(openssl rand -base64 32)"

# 3. Argo CD syncs the rest from this directory automatically.
#    Or force-sync the first time:
kubectl -n argocd patch application openwebui --type merge \
  -p '{"operation":{"sync":{}}}'
```

Then open `http://openwebui.10.0.0.120.nip.io`. The first account
created is admin.

## What's not in git

| Secret | Created by | Why not in git |
|---|---|---|
| `openwebui-db` | `ansible/postgres.yml` | Password lives in `$OPENWEBUI_DB_PASSWORD` |
| `openwebui-auth` | manual one-shot above | Session key, no value committing |

Argo CD ignores both — only the Deployment / Service / Ingress / PVC are
under GitOps.
