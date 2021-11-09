# Argo CD Chart

A Helm chart for ArgoCD, a declarative, GitOps continuous delivery tool for Kubernetes.

Source code can be found [here](https://argoproj.github.io/argo-cd/)

## Additional Information

This is a **community maintained** chart. This chart installs [argo-cd](https://argoproj.github.io/argo-cd/), a declarative, GitOps continuous delivery tool for Kubernetes.

The default installation is intended to be similar to the provided ArgoCD [releases](https://github.com/argoproj/argo-cd/releases).

## High Availability

This chart installs the non-HA version of ArgoCD by default. If you want to run ArgoCD in HA mode, you can use one of the example values in the next sections.
Please also have a look into the upstream [Operator Manual regarding High Availability](https://argoproj.github.io/argo-cd/operator-manual/high_availability/) to understand how scaling of ArgoCD works in detail.

> **Warning:**
> You need at least 3 worker nodes as the HA mode of redis enforces Pods to run on separate nodes.

### HA mode with autoscaling

```yaml
redis-ha:
  enabled: true

controller:
  enableStatefulSet: true

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2
```

### HA mode without autoscaling

```yaml
redis-ha:
  enabled: true

controller:
  enableStatefulSet: true

server:
  replicas: 2
  env:
    - name: ARGOCD_API_SERVER_REPLICAS
      value: '2'

repoServer:
  replicas: 2
```

### Synchronizing Changes from Original Repository

In the original [ArgoCD repository](https://github.com/argoproj/argo-cd/) an [`manifests/install.yaml`](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml) is generated using `kustomize`. It's the basis for the installation as [described in the docs](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd).

When installing ArgoCD using this helm chart the user should have a similar experience and configuration rolled out. Hence, it makes sense to try to achieve a similar output of rendered `.yaml` resources when calling `helm template` using the default settings in `values.yaml`.

To update the templates and default settings in `values.yaml` it may come in handy to look up the diff of the `manifests/install.yaml` between two versions accordingly. This can either be done directly via github and look for `manifests/install.yaml`:

https://github.com/argoproj/argo-cd/compare/v1.8.7...v2.0.0#files_bucket

Or you clone the repository and do a local `git-diff`:

```bash
git clone https://github.com/argoproj/argo-cd.git
cd argo-cd
git diff v1.8.7 v2.0.0 -- manifests/install.yaml
```

Changes in the `CustomResourceDefinition` resources shall be fixed easily by copying 1:1 from the [`manifests/crds` folder](https://github.com/argoproj/argo-cd/tree/master/manifests/crds) into this [`charts/argo-cd/crds` folder](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd/crds).

## Upgrading

### 3.13.0

This release removes the flag `--staticassets` from argocd server as it has been dropped upstream. If this flag needs to be enabled e.g for older releases of ArgoCD, it can be passed via the `server.extraArgs` field

### 3.10.2

ArgoCD has recently deprecated the flag `--staticassets` and from chart version `3.10.2` has been disabled by default
It can be re-enabled by setting `server.staticAssets.enabled` to true

### 3.8.1

This bugfix version potentially introduces a rename (and recreation) of one or more ServiceAccounts. It _only happens_ when you use one of these customization:

```yaml
# Case 1) - only happens when you do not specify a custom name (repoServer.serviceAccount.name)
repoServer:
  serviceAccount:
    create: true

# Case 2)
controller:
  serviceAccount:
    name: "" # or <nil>

# Case 3)
dex:
  serviceAccount:
    name: "" # or <nil>

# Case 4)
server:
  serviceAccount:
    name: "" # or <nil>
```

Please check if you are affected by one of these cases **before you upgrade**, especially when you use **cloud IAM roles for service accounts.** (eg. IRSA on AWS or Workload Identity for GKE)

### 3.2.*

With this minor version we introduced the evaluation for the ingress manifest (depending on the capabilities version), See [Pull Request](https://github.com/argoproj/argo-helm/pull/637).
[Issue 703](https://github.com/argoproj/argo-helm/issues/703) reported that the capabilities evaluation is **not handled correctly when deploying the chart via an ArgoCD instance**,
especially deploying on clusters running a cluster version prior to `1.19` (which misses  `Ingress` on apiVersion `networking.k8s.io/v1`).

If you are running a cluster version prior to `1.19` you can avoid this issue by directly installing chart version `3.6.0` and setting `kubeVersionOverride` like:

```yaml
kubeVersionOverride: "1.18.0"
```

Then you should no longer encounter this issue.

### 3.0.0 and above

Helm apiVersion switched to `v2`. Requires Helm `3.0.0` or above to install. [Read More](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/) on how to migrate your release from Helm 2 to Helm 3.

### 2.14.7 and above

The `matchLabels` key in the ArgoCD Application Controller is no longer hard-coded. Note that labels are immutable so caution should be exercised when making changes to this resource.

### 2.10.x to 2.11.0

The application controller is now available as a `StatefulSet` when the `controller.enableStatefulSet` flag is set to true. Depending on your Helm deployment this may be a downtime or breaking change if enabled when using HA and will become the default in 3.x.

### 1.8.7 to 2.x.x

`controller.extraArgs`, `repoServer.extraArgs` and `server.extraArgs`  are now arrays of strings instead of a map

What was

```yaml
server:
  extraArgs:
    insecure: ""
```

is now

```yaml
server:
  extraArgs:
  - --insecure
```

## Prerequisites

- Kubernetes 1.7+
- Helm v3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm install my-release argo/argo-cd
NAME: my-release
...
```

## General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersionOverrides.certmanager | string | `""` | String to override apiVersion of certmanager resources rendered by this helm chart |
| apiVersionOverrides.ingress | string | `""` | String to override apiVersion of ingresses rendered by this helm chart |
| configs.clusterCredentials | list | `[]` (See [values.yaml]) | Provide one or multiple [external cluster credentials] |
| configs.credentialTemplates | object | `{}` | Repository credentials to be used as Templates for other repos |
| configs.gpgKeys | object | `{}` (See [values.yaml]) | [GnuPG](https://argoproj.github.io/argo-cd/user-guide/gpg-verification/) keys to add to the key ring |
| configs.gpgKeysAnnotations | object | `{}` | GnuPG key ring annotations |
| configs.knownHosts.data.ssh_known_hosts | string | See [values.yaml] | Known Hosts |
| configs.knownHostsAnnotations | object | `{}` | Known Hosts configmap annotations |
| configs.repositories | object | `{}` | Repositories list to be used by applications |
| configs.repositoryCredentials | object | `{}` | *DEPRECATED:* Instead, use `configs.credentialTemplates` and/or `configs.repositories` |
| configs.secret.annotations | object | `{}` | Annotations to be added to argocd-secret |
| configs.secret.argocdServerAdminPassword | string | `""` | Bcrypt hashed admin password |
| configs.secret.argocdServerAdminPasswordMtime | string | `""` (defaults to current time) | Admin password modification time. Eg. `"2006-01-02T15:04:05Z"` |
| configs.secret.argocdServerTlsConfig | object | `{}` | Argo TLS Data |
| configs.secret.bitbucketServerSecret | string | `""` | Shared secret for authenticating BitbucketServer webhook events |
| configs.secret.bitbucketUUID | string | `""` | UUID for authenticating Bitbucket webhook events |
| configs.secret.createSecret | bool | `true` | Create the argocd-secret |
| configs.secret.extra | object | `{}` | add additional secrets to be added to argocd-secret |
| configs.secret.githubSecret | string | `""` | Shared secret for authenticating GitHub webhook events |
| configs.secret.gitlabSecret | string | `""` | Shared secret for authenticating GitLab webhook events |
| configs.secret.gogsSecret | string | `""` | Shared secret for authenticating Gogs webhook events |
| configs.styles | string | `""` (See [values.yaml]) | Define custom [CSS styles] for your argo instance. This setting will automatically mount the provided CSS and reference it in the argo configuration. |
| configs.tlsCerts | object | See [values.yaml] | TLS certificate |
| configs.tlsCertsAnnotations | object | `{}` | TLS certificate configmap annotations |
| createAggregateRoles | bool | `false` | Create clusterroles that extend existing clusterroles to interact with argo-cd crds |
| fullnameOverride | string | `""` | String to fully override `"argo-cd.fullname"` |
| global.hostAliases | list | `[]` | Mapping between IP and hostnames that will be injected as entries in the pod's hosts files |
| global.image.imagePullPolicy | string | `"IfNotPresent"` | If defined, a imagePullPolicy applied to all ArgoCD deployments |
| global.image.repository | string | `"quay.io/argoproj/argocd"` | If defined, a repository applied to all ArgoCD deployments |
| global.image.tag | string | `""` | Overrides the global ArgoCD image tag whose default is the chart appVersion |
| global.imagePullSecrets | list | `[]` | If defined, uses a Secret to pull an image from a private Docker registry or repository |
| global.networkPolicy.create | bool | `false` | Create NetworkPolicy objects for all components |
| global.networkPolicy.defaultDenyIngress | bool | `false` | Default deny all ingress traffic |
| global.podAnnotations | object | `{}` | Annotations for the all deployed pods |
| global.podLabels | object | `{}` | Labels for the all deployed pods |
| global.securityContext | object | `{}` | Toggle and define securityContext. See [values.yaml] |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `"argocd"` | Provide a name in place of `argocd` |
| openshift.enabled | bool | `false` | enables using arbitrary uid for argo repo server |
| server.additionalApplications | list | `[]` (See [values.yaml]) | Deploy ArgoCD Applications within this helm release |
| server.additionalProjects | list | `[]` (See [values.yaml]) | Deploy ArgoCD Projects within this helm release |

## ArgoCD Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| controller.args.appResyncPeriod | string | `"180"` | define the application controller `--app-resync` |
| controller.args.operationProcessors | string | `"10"` | define the application controller `--operation-processors` |
| controller.args.repoServerTimeoutSeconds | string | `"60"` | define the application controller `--repo-server-timeout-seconds` |
| controller.args.selfHealTimeout | string | `"5"` | define the application controller `--self-heal-timeout-seconds` |
| controller.args.statusProcessors | string | `"20"` | define the application controller `--status-processors` |
| controller.clusterAdminAccess.enabled | bool | `true` | Enable RBAC for local cluster deployments |
| controller.clusterRoleRules.enabled | bool | `false` | Enable custom rules for the application controller's ClusterRole resource |
| controller.clusterRoleRules.rules | list | `[]` | List of custom rules for the application controller's ClusterRole resource |
| controller.containerPort | int | `8082` | Application controller listening port |
| controller.containerSecurityContext | object | `{}` | Application controller container-level security context |
| controller.enableStatefulSet | bool | `false` | Deploy the application controller as a StatefulSet instead of a Deployment, this is required for HA capability. This is a feature flag that will become the default in chart version 3.x |
| controller.env | list | `[]` | Environment variables to pass to application controller |
| controller.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to application controller |
| controller.extraArgs | list | `[]` | Additional command line arguments to pass to application controller |
| controller.extraContainers | list | `[]` | Additional containers to be added to the application controller pod |
| controller.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the application controller |
| controller.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the application controller |
| controller.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the application controller |
| controller.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.logFormat | string | `"text"` | Application controller log format. Either `text` or `json` |
| controller.logLevel | string | `"info"` | Application controller log level |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
| controller.metrics.rules.enabled | bool | `false` | Deploy a PrometheusRule for the application controller |
| controller.metrics.rules.spec | list | `[]` | PrometheusRule.Spec for the application controller |
| controller.metrics.service.annotations | object | `{}` | Metrics service annotations |
| controller.metrics.service.labels | object | `{}` | Metrics service labels |
| controller.metrics.service.servicePort | int | `8082` | Metrics service port |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| controller.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| controller.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| controller.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| controller.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| controller.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| controller.name | string | `"application-controller"` | Application controller name string |
| controller.nodeSelector | object | `{}` | [Node selector] |
| controller.podAnnotations | object | `{}` | Annotations to be added to application controller pods |
| controller.podLabels | object | `{}` | Labels to be added to application controller pods |
| controller.priorityClassName | string | `""` | Priority class for the application controller pods |
| controller.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.replicas | int | `1` | The number of application controller pods to run. If changing the number of replicas you must pass the number as `ARGOCD_CONTROLLER_REPLICAS` as an environment variable |
| controller.resources | object | `{}` | Resource limits and requests for the application controller pods |
| controller.service.annotations | object | `{}` | Application controller service annotations |
| controller.service.labels | object | `{}` | Application controller service labels |
| controller.service.port | int | `8082` | Application controller service port |
| controller.service.portName | string | `"https-controller"` | Application controller service port name |
| controller.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| controller.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| controller.serviceAccount.create | bool | `true` | Create a service account for the application controller |
| controller.serviceAccount.name | string | `"argocd-application-controller"` | Service account name |
| controller.tolerations | list | `[]` | [Tolerations] for use with node taints |
| controller.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the application controller |
| controller.volumeMounts | list | `[]` | Additional volumeMounts to the application controller main container |
| controller.volumes | list | `[]` | Additional volumes to the application controller pod |

## Argo Repo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| repoServer.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| repoServer.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the repo server |
| repoServer.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the repo server [HPA] |
| repoServer.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the repo server [HPA] |
| repoServer.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the repo server [HPA] |
| repoServer.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the repo server [HPA] |
| repoServer.clusterAdminAccess.enabled | bool | `false` | Enable RBAC for local cluster deployments |
| repoServer.clusterRoleRules.enabled | bool | `false` | Enable custom rules for the Repo server's Cluster Role resource |
| repoServer.clusterRoleRules.rules | list | `[]` | List of custom rules for the Repo server's Cluster Role resource |
| repoServer.containerPort | int | `8081` | Configures the repo server port |
| repoServer.containerSecurityContext | object | `{}` | Repo server container-level security context |
| repoServer.env | list | `[]` | Environment variables to pass to repo server |
| repoServer.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to repo server |
| repoServer.extraArgs | list | `[]` | Additional command line arguments to pass to repo server |
| repoServer.extraContainers | list | `[]` | Additional containers to be added to the repo server pod |
| repoServer.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the repo server |
| repoServer.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the repo server |
| repoServer.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the repo server |
| repoServer.initContainers | list | `[]` | Init containers to add to the repo server pods |
| repoServer.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| repoServer.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| repoServer.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| repoServer.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| repoServer.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| repoServer.logFormat | string | `"text"` | Repo server log format: Either `text` or `json` |
| repoServer.logLevel | string | `"info"` | Repo server log level |
| repoServer.metrics.enabled | bool | `false` | Deploy metrics service |
| repoServer.metrics.service.annotations | object | `{}` | Metrics service annotations |
| repoServer.metrics.service.labels | object | `{}` | Metrics service labels |
| repoServer.metrics.service.servicePort | int | `8084` | Metrics service port |
| repoServer.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| repoServer.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| repoServer.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| repoServer.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| repoServer.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| repoServer.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| repoServer.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| repoServer.name | string | `"repo-server"` | Repo server name |
| repoServer.nodeSelector | object | `{}` | [Node selector] |
| repoServer.podAnnotations | object | `{}` | Annotations to be added to repo server pods |
| repoServer.podLabels | object | `{}` | Labels to be added to repo server pods |
| repoServer.priorityClassName | string | `""` | Priority class for the repo server |
| repoServer.rbac | list | `[]` | Repo server rbac rules |
| repoServer.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| repoServer.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| repoServer.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| repoServer.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| repoServer.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| repoServer.replicas | int | `1` | The number of repo server pods to run |
| repoServer.resources | object | `{}` | Resource limits and requests for the repo server pods |
| repoServer.service.annotations | object | `{}` | Repo server service annotations |
| repoServer.service.labels | object | `{}` | Repo server service labels |
| repoServer.service.port | int | `8081` | Repo server service port |
| repoServer.service.portName | string | `"https-repo-server"` | Repo server service port name |
| repoServer.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| repoServer.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| repoServer.serviceAccount.create | bool | `false` | Create repo server service account |
| repoServer.serviceAccount.name | string | `""` | Repo server service account name |
| repoServer.tolerations | list | `[]` | [Tolerations] for use with node taints |
| repoServer.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the repo server |
| repoServer.volumeMounts | list | `[]` | Additional volumeMounts to the repo server main container |
| repoServer.volumes | list | `[]` | Additional volumes to the repo server pod |

## Argo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server.GKEbackendConfig.enabled | bool | `false` | Enable BackendConfig custom resource for Google Kubernetes Engine |
| server.GKEbackendConfig.spec | object | `{}` | [BackendConfigSpec] |
| server.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| server.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the Argo CD server |
| server.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the Argo CD server [HPA] |
| server.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the Argo CD server [HPA] |
| server.certificate.additionalHosts | list | `[]` | Certificate manager additional hosts |
| server.certificate.domain | string | `"argocd.example.com"` | Certificate manager domain |
| server.certificate.enabled | bool | `false` | Enables a certificate manager certificate |
| server.certificate.issuer.kind | string | `nil` | Certificate manager issuer |
| server.certificate.issuer.name | string | `nil` | Certificate manager name |
| server.certificate.secretName | string | `"argocd-server-tls"` | Certificate manager secret name |
| server.clusterAdminAccess.enabled | bool | `true` | Enable RBAC for local cluster deployments |
| server.config | object | See [values.yaml] | [General Argo CD configuration] |
| server.configAnnotations | object | `{}` | Annotations to be added to ArgoCD ConfigMap |
| server.configEnabled | bool | `true` | Manage ArgoCD configmap (Declarative Setup) |
| server.containerPort | int | `8080` | Configures the server port |
| server.containerSecurityContext | object | `{}` | Servers container-level security context |
| server.env | list | `[]` | Environment variables to pass to Argo CD server |
| server.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to Argo CD server |
| server.extraArgs | list | `[]` | Additional command line arguments to pass to Argo CD server |
| server.extraContainers | list | `[]` | Additional containers to be added to the server pod |
| server.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Argo CD server |
| server.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the Argo CD server |
| server.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Argo CD server |
| server.ingress.annotations | object | `{}` | Additional ingress annotations |
| server.ingress.enabled | bool | `false` | Enable an ingress resource for the Argo CD server |
| server.ingress.extraPaths | list | `[]` | Additional ingress paths |
| server.ingress.hosts | list | `[]` | List of ingress hosts |
| server.ingress.https | bool | `false` | Uses `server.service.servicePortHttps` instead `server.service.servicePortHttp` |
| server.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| server.ingress.labels | object | `{}` | Additional ingress labels |
| server.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| server.ingress.paths | list | `["/"]` | List of ingress paths |
| server.ingress.tls | list | `[]` | Ingress TLS configuration |
| server.ingressGrpc.annotations | object | `{}` | Additional ingress annotations for dedicated [gRPC-ingress] |
| server.ingressGrpc.awsALB.backendProtocolVersion | string | `"HTTP2"` | Backend protocol version for the AWS ALB gRPC service |
| server.ingressGrpc.awsALB.serviceType | string | `"NodePort"` | Service type for the AWS ALB gRPC service |
| server.ingressGrpc.enabled | bool | `false` | Enable an ingress resource for the Argo CD server for dedicated [gRPC-ingress] |
| server.ingressGrpc.extraPaths | list | `[]` | Additional ingress paths for dedicated [gRPC-ingress] |
| server.ingressGrpc.hosts | list | `[]` | List of ingress hosts for dedicated [gRPC-ingress] |
| server.ingressGrpc.https | bool | `false` | Uses `server.service.servicePortHttps` instead `server.service.servicePortHttp` |
| server.ingressGrpc.ingressClassName | string | `""` | Defines which ingress controller will implement the resource [gRPC-ingress] |
| server.ingressGrpc.isAWSALB | bool | `false` | Setup up gRPC ingress to work with an AWS ALB |
| server.ingressGrpc.labels | object | `{}` | Additional ingress labels for dedicated [gRPC-ingress] |
| server.ingressGrpc.pathType | string | `"Prefix"` | Ingress path type for dedicated [gRPC-ingress]. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| server.ingressGrpc.paths | list | `["/"]` | List of ingress paths for dedicated [gRPC-ingress] |
| server.ingressGrpc.tls | list | `[]` | Ingress TLS configuration for dedicated [gRPC-ingress] |
| server.lifecycle | object | `{}` | Specify postStart and preStop lifecycle hooks for your argo-cd-server container |
| server.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| server.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| server.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| server.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| server.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| server.logFormat | string | `"text"` | Argo CD server log format: Either `text` or `json` |
| server.logLevel | string | `"info"` | Argo CD server log level |
| server.metrics.enabled | bool | `false` | Deploy metrics service |
| server.metrics.service.annotations | object | `{}` | Metrics service annotations |
| server.metrics.service.labels | object | `{}` | Metrics service labels |
| server.metrics.service.servicePort | int | `8083` | Metrics service port |
| server.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| server.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| server.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| server.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| server.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| server.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| server.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| server.name | string | `"server"` | Argo CD server name |
| server.nodeSelector | object | `{}` | [Node selector] |
| server.podAnnotations | object | `{}` | Annotations to be added to server pods |
| server.podLabels | object | `{}` | Labels to be added to server pods |
| server.priorityClassName | string | `""` | Priority class for the Argo CD server |
| server.rbacConfig | object | `{}` | ArgoCD rbac config ([ArgoCD RBAC policy]) |
| server.rbacConfigAnnotations | object | `{}` | Annotations to be added to ArgoCD rbac ConfigMap |
| server.rbacConfigCreate | bool | `true` | Whether or not to create the configmap. If false, it is expected the configmap will be created by something else. ArgoCD will not work if there is no configMap created with the name above. |
| server.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| server.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| server.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| server.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| server.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| server.replicas | int | `1` | The number of server pods to run |
| server.resources | object | `{}` | Resource limits and requests for the Argo CD server |
| server.route.enabled | bool | `false` | Enable an OpenShift Route for the Argo CD server |
| server.route.annotations | object | `{}` | Openshift Route annotations |
| server.route.hostname | string | `""` | Hostname of OpenShift Route |
| server.route.termination_type | string | `"passthrough"` | Openshift Route termination type |
| server.route.termination_policy| string | `"None"` | Openshift Route termination policy |
| server.service.annotations | object | `{}` | Server service annotations |
| server.service.externalIPs | list | `[]` | Server service external IPs |
| server.service.externalTrafficPolicy | string | `""` | Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints |
| server.service.labels | object | `{}` | Server service labels |
| server.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| server.service.loadBalancerSourceRanges | list | `[]` | Source IP ranges to allow access to service from |
| server.service.namedTargetPort | bool | `true` | Use named target port for argocd |
| server.service.nodePortHttp | int | `30080` | Server service http port for NodePort service type (only if `server.service.type` is set to "NodePort") |
| server.service.nodePortHttps | int | `30443` | Server service https port for NodePort service type (only if `server.service.type` is set to "NodePort") |
| server.service.servicePortHttp | int | `80` | Server service http port |
| server.service.servicePortHttpName | string | `"http"` | Server service http port name, can be used to route traffic via istio |
| server.service.servicePortHttps | int | `443` | Server service https port |
| server.service.servicePortHttpsName | string | `"https"` | Server service https port name, can be used to route traffic via istio |
| server.service.sessionAffinity | string | `""` | Used to maintain session affinity. Supports `ClientIP` and `None` |
| server.service.type | string | `"ClusterIP"` | Server service type |
| server.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| server.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| server.serviceAccount.create | bool | `true` | Create server service account |
| server.serviceAccount.name | string | `"argocd-server"` | Server service account name |
| server.staticAssets.enabled | bool | `true` | Disable deprecated flag `--staticassets` |
| server.tolerations | list | `[]` | [Tolerations] for use with node taints |
| server.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the Argo CD server |
| server.volumeMounts | list | `[]` | Additional volumeMounts to the server main container |
| server.volumes | list | `[]` | Additional volumes to the server pod |

## Dex

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dex.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| dex.containerPortGrpc | int | `5557` | Container port for gRPC access |
| dex.containerPortHttp | int | `5556` | Container port for HTTP access |
| dex.containerPortMetrics | int | `5558` | Container port for metrics access |
| dex.containerSecurityContext | object | `{}` | Dex container-level security context |
| dex.enabled | bool | `true` | Enable dex |
| dex.env | list | `[]` | Environment variables to pass to the Dex server |
| dex.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the Dex server |
| dex.extraContainers | list | `[]` | Additional containers to be added to the dex pod |
| dex.extraVolumeMounts | list | `[]` | Extra volumeMounts to the dex pod |
| dex.extraVolumes | list | `[]` | Extra volumes to the dex pod |
| dex.image.imagePullPolicy | string | `"IfNotPresent"` | Dex imagePullPolicy |
| dex.image.repository | string | `"ghcr.io/dexidp/dex"` | Dex image repository |
| dex.image.tag | string | `"v2.30.0"` | Dex image tag |
| dex.initImage.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Argo CD init image imagePullPolicy |
| dex.initImage.repository | string | `""` (defaults to global.image.repository) | Argo CD init image repository |
| dex.initImage.tag | string | `""` (defaults to global.image.tag) | Argo CD init image tag |
| dex.livenessProbe.enabled | bool | `false` | Enable Kubernetes liveness probe for Dex >= 2.28.0 |
| dex.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| dex.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| dex.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| dex.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| dex.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| dex.metrics.enabled | bool | `false` | Deploy metrics service |
| dex.metrics.service.annotations | object | `{}` | Metrics service annotations |
| dex.metrics.service.labels | object | `{}` | Metrics service labels |
| dex.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| dex.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| dex.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| dex.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| dex.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| dex.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| dex.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| dex.name | string | `"dex-server"` | Dex name |
| dex.nodeSelector | object | `{}` | [Node selector] |
| dex.podAnnotations | object | `{}` | Annotations to be added to the Dex server pods |
| dex.podLabels | object | `{}` | Labels to be added to the Dex server pods |
| dex.priorityClassName | string | `""` | Priority class for dex |
| dex.readinessProbe.enabled | bool | `false` | Enable Kubernetes readiness probe for Dex >= 2.28.0 |
| dex.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| dex.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| dex.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| dex.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| dex.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| dex.resources | object | `{}` | Resource limits and requests for dex |
| dex.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| dex.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| dex.serviceAccount.create | bool | `true` | Create dex service account |
| dex.serviceAccount.name | string | `"argocd-dex-server"` | Dex service account name |
| dex.servicePortGrpc | int | `5557` | Service port for gRPC access |
| dex.servicePortGrpcName | string | `"grpc"` | Service port name for gRPC access |
| dex.servicePortHttp | int | `5556` | Service port for HTTP access |
| dex.servicePortHttpName | string | `"http"` | Service port name for HTTP access |
| dex.servicePortMetrics | int | `5558` | Service port for metrics access |
| dex.tolerations | list | `[]` | [Tolerations] for use with node taints |
| dex.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to dex |
| dex.volumeMounts | list | `[{"mountPath":"/shared","name":"static-files"}]` | Additional volumeMounts to the dex main container |
| dex.volumes | list | `[{"emptyDir":{},"name":"static-files"}]` | Additional volumes to the dex pod |

## Redis

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| redis.containerPort | int | `6379` | Redis container port |
| redis.containerSecurityContext | object | `{}` | Redis container-level security context |
| redis.enabled | bool | `true` | Enable redis |
| redis.env | list | `[]` | Environment variables to pass to the Redis server |
| redis.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the Redis server |
| redis.extraArgs | list | `[]` | Additional command line arguments to pass to redis-server |
| redis.extraContainers | list | `[]` | Additional containers to be added to the redis pod |
| redis.image.imagePullPolicy | string | `"IfNotPresent"` | Redis imagePullPolicy |
| redis.image.repository | string | `"redis"` | Redis repository |
| redis.image.tag | string | `"6.2.4-alpine"` | Redis tag |
| redis.metrics.containerPort | int | `9121` | Port to use for redis-exporter sidecar |
| redis.metrics.enabled | bool | `false` | Deploy metrics service and redis-exporter sidecar |
| redis.metrics.image.imagePullPolicy | string | `"IfNotPresent"` | redis-exporter image PullPolicy |
| redis.metrics.image.repository | string | `"quay.io/bitnami/redis-exporter"` | redis-exporter image repository |
| redis.metrics.image.tag | string | `"1.26.0-debian-10-r2"` | redis-exporter image tag |
| redis.metrics.resources | object | `{}` | Resource limits and requests for redis-exporter sidecar |
| redis.metrics.service.annotations | object | `{}` | Metrics service annotations |
| redis.metrics.service.clusterIP | string | `"None"` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| redis.metrics.service.labels | object | `{}` | Metrics service labels |
| redis.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| redis.metrics.service.servicePort | int | `9121` | Metrics service port |
| redis.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| redis.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| redis.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| redis.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| redis.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| redis.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| redis.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| redis.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| redis.name | string | `"redis"` | Redis name |
| redis.nodeSelector | object | `{}` | [Node selector] |
| redis.podAnnotations | object | `{}` | Annotations to be added to the Redis server pods |
| redis.podLabels | object | `{}` | Labels to be added to the Redis server pods |
| redis.priorityClassName | string | `""` | Priority class for redis |
| redis.resources | object | `{}` | Resource limits and requests for redis |
| redis.securityContext | object | `{"runAsNonRoot":true,"runAsUser":999}` | Redis pod-level security context |
| redis.service.annotations | object | `{}` | Redis service annotations |
| redis.service.labels | object | `{}` | Additional redis service labels |
| redis.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| redis.serviceAccount.automountServiceAccountToken | bool | `false` | Automount API credentials for the Service Account |
| redis.serviceAccount.create | bool | `false` | Create a service account for the redis pod |
| redis.serviceAccount.name | string | `""` | Service account name for redis pod |
| redis.servicePort | int | `6379` | Redis service port |
| redis.tolerations | list | `[]` | [Tolerations] for use with node taints |
| redis.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to redis |
| redis.volumeMounts | list | `[]` | Additional volumeMounts to the redis container |
| redis.volumes | list | `[]` | Additional volumes to the redis pod |
| redis-ha.enabled | bool | `false` | Enables the Redis HA subchart and disables the custom Redis single node deployment |
| redis-ha.exporter.enabled | bool | `true` | If `true`, the prometheus exporter sidecar is enabled |
| redis-ha.haproxy.enabled | bool | `true` | Enabled HAProxy LoadBalancing/Proxy |
| redis-ha.haproxy.metrics.enabled | bool | `true` | HAProxy enable prometheus metric scraping |
| redis-ha.image.tag | string | `"6.2.4-alpine"` | Redis tag |
| redis-ha.persistentVolume.enabled | bool | `false` | Configures persistency on Redis nodes |
| redis-ha.redis.config | object | See [values.yaml] | Any valid redis config options in this section will be applied to each server (see `redis-ha` chart) |
| redis-ha.redis.config.save | string | `"\"\""` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled |
| redis-ha.redis.masterGroupName | string | `"argocd"` | Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated |

### Using AWS ALB Ingress Controller With GRPC

If you are using an AWS ALB Ingress controller, you will need to set `server.ingressGrpc.isAWSALB` to `true`. This will create a second service with the annotation `alb.ingress.kubernetes.io/backend-protocol-version: HTTP2` and modify the server ingress to add a condition annotation to route GRPC traffic to the new service.

Example:

```yaml
server:
  ingress:
    enabled: true
    annotations:
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internal
      alb.ingress.kubernetes.io/target-type: ip
  ingressGrpc:
    enabled: true
    isAWSALB: true
    awsALB:
      serviceType: ClusterIP

```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)

[ArgoCD RBAC policy]: https://argoproj.github.io/argo-cd/operator-manual/rbac/
[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[BackendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/concepts/backendconfig#backendconfigspec_v1beta1_cloudgooglecom
[CSS styles]: https://argo-cd.readthedocs.io/en/stable/operator-manual/custom-styles/
[external cluster credentials]: https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#clusters
[General Argo CD configuration]: https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#repositories
[gRPC-ingress]: https://argoproj.github.io/argo-cd/operator-manual/ingress/
[HPA]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
[MetricRelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[RelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[TopologySpreadConstraints]: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
[values.yaml]: values.yaml
