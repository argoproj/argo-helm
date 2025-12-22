# argocd-image-updater

A Helm chart for Argo CD Image Updater, a tool to automatically update the container images of Kubernetes workloads which are managed by Argo CD

To regenerate this document, from the root of this chart directory run:
```shell
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

## Installation

```console
helm install oci://ghcr.io/argoproj/argo-helm/argocd-image-updater --namespace <desired installation namespace>
```

If you still use the classic approach of installing Helm charts (non-OCI), you can do so by adding the Argo Helm repository and installing the chart with the following commands:

```console
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd-image-updater argo/argocd-image-updater --namespace <desired installation namespace>
```

The Argo CD Image Updater controller **must** be run in the same Kubernetes cluster where your Argo CD `Application` resources are managed. The current controller architecture (v1.0+) does not support connecting to a remote Kubernetes cluster to manage applications.

### Choosing the installation namespace

> You have two options for where to install the Argo CD Image Updater:
>
> #### Option 1: Install into the Argo CD namespace (Recommended)
>
> The simplest approach is to install the image updater into the same namespace as your Argo CD installation. This
> requires minimal configuration. (..)
>
> #### Option 2: Install into a separate namespace
>
> For better workload isolation, you can install the image updater into its own namespace. This use case requires
> several manual configuration steps. (..)

For the full details, please read [Installation methods] in the upstream docs.

## Prerequisites

* Helm v3.0.0+

## Changelog

For full list of changes please check ArtifactHub [changelog].

Highlighted versions provide information about additional steps that should be performed by user when upgrading to newer version.

### 1.0.3 (app version 1.0.2)

The upstream project changed the recommended installation namespace from `argocd-image-updater-system` to the same
namespace as Argo CD is installed in.

Please read [Installation methods] and/or [PR #1356] for more information.

### 1.0.0

This chart release includes the upstream breaking changes introduced in Argo CD Image Updater 1.0.0.
Please read the migration docs carefully: https://argocd-image-updater.readthedocs.io/en/stable/configuration/migration/

### Registries

Argo CD Image Updater natively supports the following registries (as mentioned in [Configuration of Container Registries]):

- Docker Hub
- Google Container Registry
- RedHat Quay
- GitHub Container Registry
- GitHub Docker Packages

If you need support for ECR, you can reference this issue, [Support ECR authentication], for configuration. You can use the `authScripts` values to configure the scripts that are needed to authenticate with ECR.

The `config.registries` value can be used exactly as it looks in the documentation as it gets dumped directly into a configmap in this chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Kubernetes affinity settings for the deployment |
| authScripts.enabled | bool | `false` | Whether to mount the defined scripts that can be used to authenticate with a registry, the scripts will be mounted at `/scripts` |
| authScripts.name | string | `"argocd-image-updater-authscripts"` | Name of the authentication scripts ConfigMap |
| authScripts.scripts | object | `{}` | Map of key-value pairs where the key consists of the name of the script and the value the contents. |
| config."git.commit-message-template" | string | `""` | Changing the Git commit message |
| config."git.commit-sign-off" | bool | `false` | Enables sign off on commits |
| config."git.commit-signing-key" | string | `""` | Path to public SSH key mounted in container, or GPG key ID used to sign commits |
| config."git.commit-signing-method" | string | `""` | Method used to sign Git commits. `openpgp` or `ssh` |
| config."git.email" | string | `""` | E-Mail address to use for Git commits |
| config."git.user" | string | `""` | Username to use for Git commits |
| config."kube.events" | bool | `false` | Disable kubernetes events |
| config."log.level" | string | `"info"` | Argo CD Image Update log level |
| config.name | string | `"argocd-image-updater-config"` | Name of the ConfigMap |
| config.registries | list | `[]` | Argo CD Image Updater registries list configuration. More information [here](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/). |
| config.sshConfig.config | string | `""` | Argo CD Image Updater ssh client parameter configuration |
| config.sshConfig.name | string | `"argocd-image-updater-ssh-config"` | Name of the sshConfig ConfigMap |
| containerPorts.health | int | `8081` | Port for the probe endpoint |
| containerPorts.metrics | int | `8443` | Port for the metrics |
| containerPorts.webhook | int | `8082` | Port for the webhook events |
| crds.additionalLabels | object | `{}` | Additional labels to be added to all CRDs |
| crds.annotations | object | `{}` | Annotations to be added to all CRDs |
| crds.install | bool | `true` | Install and upgrade CRDs |
| crds.keep | bool | `true` | Keep CRDs on chart uninstall |
| createClusterRoles | bool | `true` | Create cluster roles for cluster-wide installation. |
| dualStack.ipFamilies | list | `[]` | IP families that should be supported and the order in which they should be applied to ClusterIP as well. Can be IPv4 and/or IPv6. |
| dualStack.ipFamilyPolicy | string | `""` | IP family policy to configure dual-stack see [Configure dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services) |
| extraArgs | list | `[]` | Extra arguments for argocd-image-updater not defined in `config.argocd`. If a flag contains both key and value, they need to be split to a new entry. |
| extraEnv | list | `[]` | Extra environment variables for argocd-image-updater. |
| extraEnvFrom | list | `[]` | Extra envFrom to pass to argocd-image-updater |
| extraObjects | list | `[]` | Extra K8s manifests to deploy for argocd-image-updater. |
| fullnameOverride | string | `""` | Global fullname (argocd-image-updater.fullname in _helpers.tpl) override |
| image.pullPolicy | string | `"Always"` | Default image pull policy |
| image.repository | string | `"quay.io/argoprojlabs/argocd-image-updater"` | Default image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | ImagePullSecrets for the image updater deployment |
| ingress.annotations | object | `{}` | Additional ingress annotations |
| ingress.enabled | bool | `false` | Enable an ingress resource for the deployment |
| ingress.extraHosts | list | `[]` (See [values.yaml]) | The list of additional hostnames to be covered by ingress record |
| ingress.extraPaths | list | `[]` (See [values.yaml]) | Additional ingress paths |
| ingress.hostname | string | `""` (defaults to global.domain) | deployment hostname |
| ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| ingress.labels | object | `{}` | Additional ingress labels |
| ingress.path | string | `"/webhook"` | The path to deployment |
| ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Init containers to add to the image updater pod |
| metrics.enabled | bool | `false` | Deploy metrics service |
| metrics.service.annotations | object | `{}` | Metrics service annotations |
| metrics.service.labels | object | `{}` | Metrics service labels |
| metrics.service.servicePort | int | `8443` | Metrics service port |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| nameOverride | string | `""` | Global name (argocd-image-updater.name in _helpers.tpl) override |
| namespaceOverride | string | `""` | Global namespace (argocd-image-updater.namespace in _helpers.tpl) override |
| nodeSelector | object | `{}` | Kubernetes nodeSelector settings for the deployment |
| podAnnotations | object | `{}` | Pod Annotations for the deployment |
| podLabels | object | `{}` | Pod Labels for the deployment |
| podSecurityContext | object | See [values.yaml] | Pod security context settings for the deployment |
| priorityClassName | string | `""` | Priority class for the deployment |
| rbac.enabled | bool | `true` | Enable RBAC creation |
| replicaCount | int | `1` | Replica count for the deployment. It is not advised to run more than one replica. |
| resources | object | `{}` | Pod memory and cpu resource settings for the deployment |
| securityContext | object | See [values.yaml] | Security context settings for the deployment |
| service.annotations | object | `{}` | Service annotations |
| service.externalIPs | list | `[]` | Service external IPs |
| service.externalTrafficPolicy | string | `"Cluster"` | Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerClass | string | `""` | The class of the load balancer implementation |
| service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| service.loadBalancerSourceRanges | list | `[]` | Source IP ranges to allow access to service from |
| service.nodePortHttp | int | `30080` | Service http port for NodePort service type (only if `service.type` is set to "NodePort") |
| service.nodePortHttps | int | `30443` | Service https port for NodePort service type (only if `service.type` is set to "NodePort") |
| service.port | int | `8080` | Service http port |
| service.servicePortHttpName | string | `"server-port"` | Service http port name, can be used to route traffic via istio |
| service.sessionAffinity | string | `"None"` | Used to maintain session affinity. Supports `ClientIP` and `None` |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.labels | object | `{}` | Labels to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Kubernetes toleration settings for the deployment |
| updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |
| volumeMounts | list | `[]` | Additional volumeMounts to the image updater main container |
| volumes | list | `[]` | Additional volumes to the image updater pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[Configuration of Container Registries]: https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/
[Support ECR authentication]: https://github.com/argoproj-labs/argocd-image-updater/issues/112
[Installation methods]: https://github.com/argoproj-labs/argocd-image-updater/blob/v1.0.2/docs/install/installation.md#installation-methods
[PR #1356]: https://github.com/argoproj-labs/argocd-image-updater/pull/1356
