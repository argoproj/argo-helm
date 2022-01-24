## ArgoCD Operator

This is a **community maintained** chart. It installs the [argocd-operator](https://argocd-operator.readthedocs.io/) for managing ArgoCD clusters.

To regenerate this document, from the root of this chart directory run:

```shell
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

## Notes on CRD Installation

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--skip-crds` when installing the chart.

You can install the CRDs manually from `crds` folder.

## Values

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| operator.clusterDomain | string | `""` |  |
| operator.image.pullPolicy | string | `"IfNotPresent"` |  |
| operator.image.repository | string | `"statcan/argocd-operator"` |  |
| operator.image.tag | string | `"v0.1.0"` |  |
| operator.imagePullSecrets | list | `[]` |  |
| operator.nsClusterConfig | string | `""` |  |
| operator.nsToWatch | string | `"argo-cd-system"` |  |
| operator.podAnnotations | object | `{}` |  |
| operator.podLabels | object | `{}` |  |
| operator.replicaCount | int | `1` |  |
| operator.resources.requests.cpu | string | `"200m"` |  |
| operator.resources.requests.ephemeral-storage | string | `"500Mi"` |  |
| operator.resources.requests.memory | string | `"256Mi"` |  |
| operator.securityContext.fsGroup | int | `1000` |  |
| operator.securityContext.runAsGroup | int | `1000` |  |
| operator.securityContext.runAsNonRoot | bool | `true` |  |
| operator.securityContext.runAsUser | int | `1000` |  |

### Vault

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| vault.auth.rolePrefix | string | `"argocd_"` |  |
| vault.auth.type | string | `"k8s"` |  |
| vault.auth.url | string | `"http://vault.default:8200"` |  |
| vault.enabled | bool | `false` |  |

### Plugin Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pluginConfig | string | `"# If the argocd-vault-plugin is not enabled,\n# then obviously these will not work.\n- name: argocd-vault-plugin\n  generate:\n    command: [\"argocd-vault-plugin\"]\n    args: [\"-s\", \"argocd-vault-secret\", \"generate\", \"./\"]\n- name: argocd-vault-plugin-helm\n  generate:\n    command: [\"sh\", \"-c\"]\n    args: [\"helm template . > all.yaml && argocd-vault-plugin -s argocd-vault-secret generate all.yaml\"]\n- name: argocd-vault-plugin-kustomize\n  generate:\n    command: [\"sh\", \"-c\"]\n    args: [\"kustomize build . > all.yaml && argocd-vault-plugin -s argocd-vault-secret generate all.yaml\"]\n"` |  |
