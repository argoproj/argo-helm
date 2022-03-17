# argocd-image-updater

A Helm chart for Argo CD Image Updater, a tool to automatically update the container images of Kubernetes workloads which are managed by Argo CD

To regenerate this document, from the root of this chart directory run:
```shell
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

## Installation

```console
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd-image-updater argo/argocd-image-updater
```

You will also need to run through the [secret setup documentation](https://argocd-image-updater.readthedocs.io/en/stable/install/start/#connect-using-argo-cd-api-server) so ArgoCD ImageUpdater can talk to the ArgoCD API (until its automated in this chart).

## Prerequisites

* Helm v3.0.0+

## Configuration options

In order for your deployment of ArgoCD Image Updater to be successful, you will need to make sure you set the correct configuration options described in detail on the [argocd-image-updater flags page](https://argocd-image-updater.readthedocs.io/en/stable/install/running/#flags).

All of the `argocd-` prefixed flags, which tell `argocd-image-updater` how your ArgoCD instance is setup, are set in the `config.argocd` values block. For instance:

```yaml
config:
  argocd:
    grpcWeb: false
    serverAddress: "http://argocd.argo"
    insecure: true
    plaintext: true
```

Any additional arguments mentioned on the [argocd-image-updater flags page](https://argocd-image-updater.readthedocs.io/en/stable/install/running/#flags) can be configured using the `extraArgs` value, like so.

### ArgoCD API key

If you are unable to install Argo CD Image Updater into the same Kubernetes cluster you might configure it to use API of your Argo CD installation.
Please also read [the documentation](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/).

```yaml
config:
  argocd:
    token: <your_secret_here>
```

If you specify a token value the secret will be created.

### Registries

ArgoCD Image Updater natively supports the following registries (as mentioned in [the documentation](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/)):

- Docker Hub
- Google Container Registry
- RedHat Quay
- GitHub Container Registry
- GitHub Docker Packages

If you need support for ECR, you can reference [this issue](https://github.com/argoproj-labs/argocd-image-updater/issues/112) for configuration. You can use the `authScripts` values to configure the scripts that are needed to authenticate with ECR.

The `config.registries` value can be used exactly as it looks in the documentation as it gets dumped directly into a configmap in this chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Kubernetes affinity settings for the deployment |
| authScripts.enabled | bool | `false` | Whether to mount the defined scripts that can be used to authenticate with a registry, the scripts will be mounted at `/scripts` |
| authScripts.scripts | object | `{}` | Map of key-value pairs where the key consists of the name of the script and the value the contents |
| config.applicationsAPIKind | string | `""` | API kind that is used to manage Argo CD applications (`kubernetes` or `argocd`) |
| config.argocd.grpcWeb | bool | `true` | Use the gRPC-web protocol to connect to the Argo CD API |
| config.argocd.insecure | bool | `false` | If specified, the certificate of the Argo CD API server is not verified. |
| config.argocd.plaintext | bool | `false` | If specified, use an unencrypted HTTP connection to the ArgoCD API instead of TLS. |
| config.argocd.serverAddress | string | `""` | Connect to the Argo CD API server at server address |
| config.argocd.token | string | `""` | If specified, the secret with ArgoCD API key will be created. |
| config.disableKubeEvents | bool | `false` | Disable kubernetes events |
| config.gitCommitMail | string | `""` | E-Mail address to use for Git commits |
| config.gitCommitTemplate | string | `""` | Changing the Git commit message |
| config.gitCommitUser | string | `""` | Username to use for Git commits |
| config.logLevel | string | `"info"` | ArgoCD Image Update log level |
| config.registries | list | `[]` | ArgoCD Image Updater registries list configuration. More information [here](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/) |
| config.sshConfig | object | `{}` | ArgoCD Image Updater ssh client parameter configuration. |
| extraArgs | list | `[]` | Extra arguments for argocd-image-updater not defined in `config.argocd`. If a flag contains both key and value, they need to be split to a new entry |
| extraEnv | list | `[]` | Extra environment variables for argocd-image-updater |
| fullnameOverride | string | `""` | Global fullname (argocd-image-updater.fullname in _helpers.tpl) override |
| image.pullPolicy | string | `"Always"` | Default image pull policy |
| image.repository | string | `"quay.io/argoprojlabs/argocd-image-updater"` | Default image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | ImagePullSecrets for the image updater deployment |
| metrics.enabled | bool | `false` | Deploy metrics service |
| metrics.service.annotations | object | `{}` | Metrics service annotations |
| metrics.service.labels | object | `{}` | Metrics service labels |
| metrics.service.servicePort | int | `8081` | Metrics service port |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| nameOverride | string | `""` | Global name (argocd-image-updater.name in _helpers.tpl) override |
| nodeSelector | object | `{}` | Kubernetes nodeSelector settings for the deployment |
| podAnnotations | object | `{}` | Pod Annotations for the deployment |
| podSecurityContext | object | `{}` | Pod security context settings for the deployment |
| rbac.enabled | bool | `true` | Enable RBAC creation |
| replicaCount | int | `1` | Replica count for the deployment. It is not advised to run more than one replica. |
| resources | object | `{}` | Pod memory and cpu resource settings for the deployment |
| securityContext | object | `{}` | Security context settings for the deployment |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Kubernetes toleration settings for the deployment |
| updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[MetricRelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs
[RelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
