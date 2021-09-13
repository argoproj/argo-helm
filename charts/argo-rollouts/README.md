# Argo Rollouts Chart

A Helm chart for Argo Rollouts, progressive delivery for Kubernetes.

Source code can be found [here](https://github.com/argoproj/argo-rollouts)

## Additional Information

This is a **community maintained** chart. This chart installs [argo-rollouts](https://argoproj.github.io/argo-rollouts/), progressive delivery for Kubernetes.

The default installation is intended to be similar to the provided Argo Rollouts [releases](https://github.com/argoproj/argo-rollouts/releases).

## Prerequisites

- Kubernetes 1.7+
- Helm v3.0.0+


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install my-release argo/argo-rollouts
```

If dashboard is installed by `--set dashboard.enabled=true`, checkout the argo-rollouts dashboard by
`kubectl port-forward service/argo-rollouts-dashboard 31000:3100` and pointing the browser to `localhost:31000`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterInstall | bool | `true` | `false` runs controller in namespaced mode (does not require cluster RBAC) |
| controller.component | string | `"rollouts-controller"` | Value of label `app.kubernetes.io/component` |
| controller.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| controller.image.registry | string | `quay.io` | Registry to use |
| controller.image.repository | string | `"argoproj/argo-rollouts"` | Repository to use |
| controller.image.tag | string | `""` | Overrides the image tag (default is the chart appVersion) |
| controller.resources | object | `{}` | Resource limits and requests for the controller pods. |
| controller.tolerations | list | `[]` | [Tolerations for use with node taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| controller.affinity | object | `{}` | [Assign custom affinity rules to the deployment](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| controller.nodeSelector | object | `{}` | [Node selector](https://kubernetes.io/docs/user-guide/node-selection/) |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
| controller.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.metrics.serviceMonitor.additionalAnnotations | object | `{}` | Annotations to be added to the ServiceMonitor |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` | Labels to be added to the ServiceMonitor |
| imagePullSecrets | list | `[]` | Registry secret names as an array |
| installCRDs | bool | `true` | Install and upgrade CRDs |
| crdAnnotations | object | `{}` | Annotations to be added to all CRDs |
| podAnnotations | object | `{}` | Annotations to be added to the Rollout pods |
| podLabels | object | `{}` | Labels to be added to the Rollout pods |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| podSecurityContext | object | `{"runAsNonRoot": true}` | Security Context to set on pod level |
| containerSecurityContext | object | `{}` | Security Context to set on container level |
| dashboard.enabled | bool | `false` | Deploy dashboard server |
| dashboard.component | string | `"rollouts-dashboard"` | Value of label `app.kubernetes.io/component` |
| dashboard.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| dashboard.image.registry | string | `quay.io` | Registry to use |
| dashboard.image.repository | string | `"argoproj/kubectl-argo-rollouts"` | Repository to use |
| dashboard.image.tag | string | `""` | Overrides the image tag (default is the chart appVersion) |
| dashboard.resources | object | `{}` | Resource limits and requests for the dashboard pods. |
| dashboard.tolerations | list | `[]` | [Tolerations for use with node taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| dashboard.affinity | object | `{}` | [Assign custom affinity rules to the deployment](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| dashboard.nodeSelector | object | `{}` | [Node selector](https://kubernetes.io/docs/user-guide/node-selection/) |
| dashboard.podSecurityContext | object | `{"runAsNonRoot": true}` | Security Context to set on pod level |
| dashboard.containerSecurityContext | object | `{}` | Security Context to set on container level |
| dashboard.serviceAccount.create | bool | `true` | Specifies whether a dashboard service account should be created |
| dashboard.serviceAccount.annotations | object | `{}` | Annotations to add to the dashboard service account |
| dashboard.serviceAccount.name | string | `""` | The name of the dashboard service account to use. If not set and create is true, a name is generated using the fullname template |

## Upgrading

### To 2.0.0

* The argo-rollouts dashboard is added to the template and can be enabled by setting `dashboard.enabled=true`.
* There is a breaking change where the selector label `app.kubernetes.io/component: {{ .Values.controller.component }}` is added to rollout's deployment and service in order to distinguish between the controller and the dashboard component.
  To upgrade an existing installation, please **add the `--force` parameter** to the `helm upgrade` command or **delete the Deployment and Service resource** before you upgrade. This is necessary because Deployment's label selector is immutable.

### To 1.0.0

* This is a breaking change which only supports Helm v3.0.0+ now. If you still use Helm v2, please consider upgrading because v2 is EOL since November 2020.  
  To migrate to Helm v3 please have a look at the [Helm 2to3 Plugin](https://github.com/helm/helm-2to3). This tool will convert the existing ConfigMap used for Tiller to a Secret of type `helm.sh/release.v1`.
* `quay.io` is the default registry now
* We introduce a template function for the labels here to reduce code duplication. This also affects the Deployment `matchLabels` selector.  
  To upgrade an existing installation, please **add the `--force` parameter** to the `helm upgrade` command or **delete the Deployment resource** before you upgrade. This is necessary because Deployment's label selector is immutable.
* All resources are now prefixed with the template `"argo-rollouts.fullname"`.
  This enables the users to override resource names via the `nameOverride` and `fullnameOverride` parameters.
* Breaking parameters update
  * `securityContext` was renamed to `containerSecurityContext`
  * Added `controller.image.registry`. Prior to this chart version you had to override the registry via `controller.image.repository`
