# deploy/

Kubernetes manifests for apps running in the cluster.

```
deploy/
└── whoami/         # test app — proves k3s + Traefik + Ingress wiring
    └── whoami.yaml
```

## Apply an app

```bash
export KUBECONFIG=~/homelab/.kube/home.yaml
kubectl apply -f deploy/whoami/
kubectl -n prod get pods -w           # watch them come up
```

## Test it

```bash
# nip.io trick: any FQDN like whoami.10.10.20.120.nip.io resolves to 10.10.20.120
curl http://whoami.10.10.20.120.nip.io

# Or, from a browser, just open that URL.
```

You should see the request reflected back: pod name, IP, headers, etc. Two
replicas → repeated calls hit different pods.

## Adding TLS (once you have a real domain)

1. Point a real domain (e.g., `api.yourdomain.com`) at your public IP
2. Port-forward 80 + 443 on your UniFi gateway → worker IP (10.10.20.120)
3. In the Ingress, swap the nip.io host for the real one, uncomment:
   - the `cert-manager.io/cluster-issuer: letsencrypt` annotation
   - the `tls:` block at the bottom
4. `kubectl apply -f deploy/whoami/`
5. cert-manager + Traefik handle the rest — your cert is issued within ~1 min

## Using the Postgres secret

For apps that need DB access, mount the existing `postgres-app` Secret created
by `ansible/postgres.yml`:

```yaml
        env:
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: postgres-app
                key: DATABASE_URL
```

All credentials, host, DB name come from that one Secret.
