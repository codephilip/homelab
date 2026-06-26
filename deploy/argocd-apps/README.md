# deploy/argocd-apps/

Argo CD `Application` definitions — one file per in-cluster app. The root
"app-of-apps" Application (installed by `ansible/argocd.yml`) watches this
directory and creates a child Application for each file. Each child syncs
the manifests under `deploy/<app>/`.

## Add a new app

1. Drop manifests in `deploy/<myapp>/` (Deployment, Service, Ingress, …)
2. Create `deploy/argocd-apps/<myapp>.yaml` modeled after the others
3. `git push` — Argo CD picks it up within ~3 minutes (or click "Refresh"
   on the root app in the UI)

## Why app-of-apps and not Argo CD Projects?

Same outcome (everything under GitOps), much simpler mental model. Each
Application is a flat file, Argo's "Sync" button per-app does the right
thing, and there's no Project hierarchy to maintain.
