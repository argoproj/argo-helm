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

**Note**: You may also use helm hooks for auto-configuring argocd-image-updater-secret as described in the **Secret Hook** section below.

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

### Registries

ArgoCD Image Updater natively supports the following registries (as mentioned in [the documentation](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/)):

- Docker Hub
- Google Container Registry
- RedHat Quay
- GitHub Container Registry
- GitHub Docker Packages

If you need support for ECR, you can reference [this issue](https://github.com/argoproj-labs/argocd-image-updater/issues/112) for configuration. You can use the `authScripts` values to configure the scripts that are needed to authenticate with ECR.

The `config.registries` value can be used exactly as it looks in the documentation as it gets dumped directly into a configmap in this chart.

### Secret Hook

Requirements:

- Account with apiKey capability
- Account authorized to create/delete tokens

**Note**: Using the hooks to automatically configure the secret can take some time on hosts with slow internet connection. This is because the hook jobs use `apt update && apt install curl jq -y;` at the beginning. We can make the hook jobs faster if we create a container that already has preinstalled these dependencies

To configure ArgoCD Image Updater to create the secret automatically you have the following options

#### Create a secret automatically by using ArgoCD initial admin token secret

This method is most desirable because:

- ArgoCD admin is authorized by default to be able and manage account tokens.
- It requires only an account that has `apiKey` capability to be present in ArgoCD
- You do not pass any credentials in the helm values. The hook job will mount and read the admin admin secret automatically

Setting option `hooks.argocd.mountInitialAdminSecret: true` will configure Image Updater to read the admin secret and use it to create a token for the account with the apiKey capability.

Options required:

- hooks.argocd.mountInitialAdminSecret: true
- hooks.argocd.username: "admin"
- hooks.secret.accountName: Account With apiKey Capability

**Notes**: Option `hooks.argocd.username` must be `admin` since the secret that is mount and read is for that user. If the future we will add an option to also specify which secret should be read, in turn allowing the username to take any value

Configuration flow:

- Admin secret is mounted
- A new sessions is created via the hook job
- Session is used to create a token for `hooks.secret.accountName`
- Token is saved in Kubernetes secret `argocd-image-updater-secret`

#### Use the credentials from an ArgoCD account that can create and delete tokens

This does essentially what the previous method from above does, but instead of reading the initial admin token from Kubernetes, we provide the credentials of an account that can create and delete tokens.

This method is dessirable if:

- You have disabled admin account
- ArgoCD Image Updater is deployed in a namespace that is different for that which ArgoCD has been deployed

Options required:

- hooks.argocd.password: somePassword
- hooks.argocd.username: someUsername
- hooks.secret.accountName: Account With apiKey Capability

#### Use a token that you have already exported

This method desirable if:

- You already have created tokens for an account
- You want to manage the account tokens via external tooling
- You want the helm install/upgrade action to be as fast as possible

This method is simple and it only requires to pass the following options

- hooks.secret.apiKey: someAPIKey

Configuration flow:

- Token is read from `values.yaml`, then encoded with b64 and finally saved as a secret

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
| config.disableKubeEvents | bool | `false` | Disable kubernetes events |
| config.gitCommitMail | string | `""` | E-Mail address to use for Git commits |
| config.gitCommitTemplate | string | `""` | Changing the Git commit message |
| config.gitCommitUser | string | `""` | Username to use for Git commits |
| config.logLevel | string | `"info"` | ArgoCD Image Update log level |
| config.registries | list | `[]` | ArgoCD Image Updater registries list configuration. More information [here](https://argocd-image-updater.readthedocs.io/en/stable/configuration/registries/) |
| extraArgs | list | `[]` | Extra arguments for argocd-image-updater not defined in `config.argocd`. If a flag contains both key and value, they need to be split to a new entry |
| extraEnv | list | `[]` | Extra environment variables for argocd-image-updater |
| fullnameOverride | string | `""` | Global fullname (argocd-image-updater.fullname in _helpers.tpl) override |
| hooks | object | `{"argocd":{"mountInitialAdminSecret":false,"password":"","username":"admin"},"debug":false,"enabled":false,"kubernetes":{"apiServer":"https://kubernetes.default.svc","cacert":"","serviceAccountToken":""},"secret":{"accountName":"image-updater","apiKey":"","force":false}}` | Chart hooks for creating argocd-image-updater-secret secret |
| hooks.argocd | object | `{"mountInitialAdminSecret":false,"password":"","username":"admin"}` | Argocd credentials that can be used to generate or export tokens |
| hooks.argocd.mountInitialAdminSecret | bool | `false` | Should be used only if image-updater is deployed in the same cluster and namespace as argocd. Note-1: If you mount the initial admin secret then         .hooks.argocd.password must be "". Note-2: If you set this option, then .hooks.argocd.username must be         set to "admin" since the initial admin token is meant for         that user. |
| hooks.argocd.password | string | `""` | The password of the account that will be used to manage tokens Note: If you set this to anything than "", then you must set .hooks.argocd.mountInitialAdminSecret to false |
| hooks.argocd.username | string | `"admin"` | Default admin account. Can be set to a different account that is authorized to manage tokens. If you want this account to also be used for authN/Z by image-updater then set hooks.secret.accountName the same as this |
| hooks.debug | bool | `false` | Debug will enable shell debug set -x on hook jobs. Warning: Do not use DEBUG=true for production. If you do, ensure          that only the desired set of users are able to get logs          from the image-updater pods & jobs.          With DEBUG set to true, all secrets and tokens will be          visible during kubectl logs ... image-updater... |
| hooks.enabled | bool | `false` | Must be set to true to enable chart hoooks |
| hooks.kubernetes | object | `{"apiServer":"https://kubernetes.default.svc","cacert":"","serviceAccountToken":""}` | (Optional) Kubernetes cluster options. Note: Usually the options from the map will work out of the box,        but they have been included in case you want to use a specific       token from a service account or a different apiServer endpoint |
| hooks.kubernetes.apiServer | string | `"https://kubernetes.default.svc"` | The Kubernetes API Server endpoint. Must be routable from the network that image-updater will be deployed |
| hooks.kubernetes.cacert | string | `""` | (Required if hooks.kubernetes.serviceAccountToken is anything else but "") Base64 encoded API Server Root CA of the cluster that argocd image updater has been / will be deployed |
| hooks.kubernetes.serviceAccountToken | string | `""` | Base64 encoded token from the service account you want to use for configurring image-updater secret in the namespace of argocd. Note: The service account in the kubernetes cluster that hosts         argocd image updater must have permissions to create secrets         and list secret named "argocd-image-updater-secret" |
| hooks.secret | object | `{"accountName":"image-updater","apiKey":"","force":false}` | Map with options about the actual token that will be used by the image-updater |
| hooks.secret.accountName | string | `"image-updater"` | The account name you want to use for generating tokens. The account must exist in argocd and must also have "get" and "update" RBAC application permissions |
| hooks.secret.apiKey | string | `""` | This is the apiKey that image-updater will use to authendicate with argocd. Note-1: If you set this to anything than "" then HOOK JOBS WILL NOT RUN and instead an "argocd-image-updater-secret" secret will be created inplace Note-2: apiKey is not encoded. |
| hooks.secret.force | bool | `false` | Setting this to true will force hook jobs to delete a token if it exists for a specific account and then create a new one |
| image.pullPolicy | string | `"Always"` | Default image pull policy |
| image.repository | string | `"argoprojlabs/argocd-image-updater"` | Default image repository |
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

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.6.0](https://github.com/norwoodj/helm-docs/releases/v1.6.0)

[MetricRelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs
[RelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
