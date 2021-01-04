# SMA CUSTOM CONFIGURATION

## Installing

### Prerequisites

`Please install helm 3.x and configure your kubernetes cluster.`

With the command `helm version`, make sure that you have:
- Helm v3 [installed](https://helm.sh/docs/using_helm/#installing-helm)

Add Traefik's chart repository to Helm:

```bash
helm repo add traefik https://helm.traefik.io/traefik
```

You can update the chart repository by running:

```bash
helm repo update
```

### Deploying Traefik vit custom values:

```bash
helm install traefik -f values.yaml traefik/traefik
```

`Arbitrarily --values can be used -f instead!`

#### Warning

If you are using Helm v2

You have to deploy CRDs manually with the following command:

```
kubectl apply -f traefik/crds
```

### Exposing the Traefik dashboard

Another way would be to apply your own configuration, for instance,
by defining and applying an IngressRoute CRD (`kubectl apply -f dashboard.yaml`):

```yaml
# dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.sma.cmsalz.ibm.allianz`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```
