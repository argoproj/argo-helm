# Argo CD Chart

A Helm chart for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes.

Source code can be found [here](https://argoproj.github.io/argo-cd/)

## Additional Information

This is a **community maintained** chart. This chart installs [argo-cd](https://argoproj.github.io/argo-cd/), a declarative, GitOps continuous delivery tool for Kubernetes.

The default installation is intended to be similar to the provided Argo CD [releases](https://github.com/argoproj/argo-cd/releases).

If you want to avoid including sensitive information unencrypted (clear text) in your version control, make use of the [declarative set up](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) of Argo CD.
For instance, rather than adding repositories and their keys in your Helm values, you could deploy [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) with contents as seen in this [repositories section](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) or any other secrets manager service (i.e. HashiCorp Vault, AWS/GCP Secrets Manager, etc.).

## High Availability

This chart installs the non-HA version of Argo CD by default. If you want to run Argo CD in HA mode, you can use one of the example values in the next sections.
Please also have a look into the upstream [Operator Manual regarding High Availability](https://argoproj.github.io/argo-cd/operator-manual/high_availability/) to understand how scaling of Argo CD works in detail.

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

In the original [Argo CD repository](https://github.com/argoproj/argo-cd/) an [`manifests/install.yaml`](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml) is generated using `kustomize`. It's the basis for the installation as [described in the docs](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd).

When installing Argo CD using this helm chart the user should have a similar experience and configuration rolled out. Hence, it makes sense to try to achieve a similar output of rendered `.yaml` resources when calling `helm template` using the default settings in `values.yaml`.

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

### Custom resource definitions

Helm cannot upgrade custom resource definitions [by design](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations).

Please use `kubectl` to upgrade CRDs manually from [crds](crds/) folder or via the manifests from the upstream project repo:

```bash
kubectl apply -k https://github.com/argoproj/argo-cd.git/manifests/crds?ref=<appVersion>

# Eg. version v2.3.3
kubectl apply -k https://github.com/argoproj/argo-cd.git/manifests/crds?ref=v2.3.3
```

### 4.3.*

With this minor version, the notification notifier's `service.slack` is no longer configured by default.

### 4.0.0 and above

This helm chart version deploys Argo CD v2.3. The Argo CD Notifications and ApplicationSet are part of Argo CD now. You no longer need to install them separately. The Notifications and ApplicationSet components **are bundled into default** Argo CD installation.
Please read the [v2.2 to 2.3 upgrade instructions] in the upstream repository.

### 3.13.0

This release removes the flag `--staticassets` from argocd server as it has been dropped upstream. If this flag needs to be enabled e.g for older releases of Argo CD, it can be passed via the `server.extraArgs` field

### 3.10.2

Argo CD has recently deprecated the flag `--staticassets` and from chart version `3.10.2` has been disabled by default
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
[Issue 703](https://github.com/argoproj/argo-helm/issues/703) reported that the capabilities evaluation is **not handled correctly when deploying the chart via an Argo CD instance**,
especially deploying on clusters running a cluster version prior to `1.19` (which misses  `Ingress` on apiVersion `networking.k8s.io/v1`).

If you are running a cluster version prior to `1.19` you can avoid this issue by directly installing chart version `3.6.0` and setting `kubeVersionOverride` like:

```yaml
kubeVersionOverride: "1.18.0"
```

Then you should no longer encounter this issue.

### 3.0.0 and above

Helm apiVersion switched to `v2`. Requires Helm `3.0.0` or above to install. [Read More](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/) on how to migrate your release from Helm 2 to Helm 3.

### 2.14.7 and above

The `matchLabels` key in the Argo CD Application Controller is no longer hard-coded. Note that labels are immutable so caution should be exercised when making changes to this resource.

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
| configs.credentialTemplatesAnnotations | object | `{}` | Annotations to be added to `configs.credentialTemplates` Secret |
| configs.gpgKeys | object | `{}` (See [values.yaml]) | [GnuPG](https://argoproj.github.io/argo-cd/user-guide/gpg-verification/) keys to add to the key ring |
| configs.gpgKeysAnnotations | object | `{}` | GnuPG key ring annotations |
| configs.knownHosts.data.ssh_known_hosts | string | See [values.yaml] | Known Hosts |
| configs.knownHostsAnnotations | object | `{}` | Known Hosts configmap annotations |
| configs.repositories | object | `{}` | Repositories list to be used by applications |
| configs.repositoriesAnnotations | object | `{}` | Annotations to be added to `configs.repositories` Secret |
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
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| fullnameOverride | string | `""` | String to fully override `"argo-cd.fullname"` |
| global.additionalLabels | object | `{}` | Additional labels to add to all resources |
| global.hostAliases | list | `[]` | Mapping between IP and hostnames that will be injected as entries in the pod's hosts files |
| global.image.imagePullPolicy | string | `"IfNotPresent"` | If defined, a imagePullPolicy applied to all Argo CD deployments |
| global.image.repository | string | `"quay.io/argoproj/argocd"` | If defined, a repository applied to all Argo CD deployments |
| global.image.tag | string | `""` | Overrides the global Argo CD image tag whose default is the chart appVersion |
| global.imagePullSecrets | list | `[]` | If defined, uses a Secret to pull an image from a private Docker registry or repository |
| global.networkPolicy.create | bool | `false` | Create NetworkPolicy objects for all components |
| global.networkPolicy.defaultDenyIngress | bool | `false` | Default deny all ingress traffic |
| global.podAnnotations | object | `{}` | Annotations for the all deployed pods |
| global.podLabels | object | `{}` | Labels for the all deployed pods |
| global.securityContext | object | `{}` | Toggle and define securityContext. See [values.yaml] |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `"argocd"` | Provide a name in place of `argocd` |
| openshift.enabled | bool | `false` | enables using arbitrary uid for argo repo server |
| server.additionalApplications | list | `[]` (See [values.yaml]) | Deploy Argo CD Applications within this helm release |
| server.additionalProjects | list | `[]` (See [values.yaml]) | Deploy Argo CD Projects within this helm release |

## Argo CD Controller

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
| controller.enableStatefulSet | bool | `true` | Deploy the application controller as a StatefulSet instead of a Deployment, this is required for HA capability. |
| controller.env | list | `[]` | Environment variables to pass to application controller |
| controller.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to application controller |
| controller.extraArgs | list | `[]` | Additional command line arguments to pass to application controller |
| controller.extraContainers | list | `[]` | Additional containers to be added to the application controller pod |
| controller.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the application controller |
| controller.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the application controller |
| controller.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the application controller |
| controller.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| controller.initContainers | list | `[]` | Init containers to add to the application controller pod |
| controller.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.logFormat | string | `"text"` | Application controller log format. Either `text` or `json` |
| controller.logLevel | string | `"info"` | Application controller log level |
| controller.metrics.applicationLabels.enabled | bool | `false` | Enables additional labels in argocd_app_labels metric |
| controller.metrics.applicationLabels.labels | list | `[]` | Additional labels |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
| controller.metrics.rules.enabled | bool | `false` | Deploy a PrometheusRule for the application controller |
| controller.metrics.rules.spec | list | `[]` | PrometheusRule.Spec for the application controller |
| controller.metrics.service.annotations | object | `{}` | Metrics service annotations |
| controller.metrics.service.labels | object | `{}` | Metrics service labels |
| controller.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| controller.metrics.service.servicePort | int | `8082` | Metrics service port |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| controller.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| controller.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| controller.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| controller.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| controller.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| controller.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| controller.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| controller.name | string | `"application-controller"` | Application controller name string |
| controller.nodeSelector | object | `{}` | [Node selector] |
| controller.pdb.annotations | object | `{}` | Annotations to be added to application controller pdb |
| controller.pdb.enabled | bool | `false` | Deploy a Poddisruptionbudget for the application controller |
| controller.pdb.labels | object | `{}` | Labels to be added to application controller pdb |
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
| repoServer.copyutil.resources | object | `{}` | Resource limits and requests for the copyutil initContainer |
| repoServer.env | list | `[]` | Environment variables to pass to repo server |
| repoServer.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to repo server |
| repoServer.extraArgs | list | `[]` | Additional command line arguments to pass to repo server |
| repoServer.extraContainers | list | `[]` | Additional containers to be added to the repo server pod |
| repoServer.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the repo server |
| repoServer.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the repo server |
| repoServer.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the repo server |
| repoServer.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
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
| repoServer.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| repoServer.metrics.service.servicePort | int | `8084` | Metrics service port |
| repoServer.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| repoServer.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| repoServer.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| repoServer.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| repoServer.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| repoServer.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| repoServer.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| repoServer.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| repoServer.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| repoServer.name | string | `"repo-server"` | Repo server name |
| repoServer.nodeSelector | object | `{}` | [Node selector] |
| repoServer.pdb.annotations | object | `{}` | Annotations to be added to Repo server pdb |
| repoServer.pdb.enabled | bool | `false` | Deploy a Poddisruptionbudget for the Repo server |
| repoServer.pdb.labels | object | `{}` | Labels to be added to Repo server pdb |
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
| repoServer.serviceAccount.create | bool | `true` | Create repo server service account |
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
| server.GKEfrontendConfig.enabled | bool | `false` | Enable FrontConfig custom resource for Google Kubernetes Engine |
| server.GKEfrontendConfig.spec | object | `{}` | [FrontendConfigSpec] |
| server.GKEmanagedCertificate.domains | list | `["argocd.example.com"]` | Domains for the Google Managed Certificate |
| server.GKEmanagedCertificate.enabled | bool | `false` | Enable ManagedCertificate custom resource for Google Kubernetes Engine. |
| server.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| server.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the Argo CD server |
| server.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the Argo CD server [HPA] |
| server.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the Argo CD server [HPA] |
| server.certificate.additionalHosts | list | `[]` | Certificate manager additional hosts |
| server.certificate.domain | string | `"argocd.example.com"` | Certificate primary domain (commonName) |
| server.certificate.duration | string | `""` | The requested 'duration' (i.e. lifetime) of the Certificate. Value must be in units accepted by Go time.ParseDuration |
| server.certificate.enabled | bool | `false` | Deploy a Certificate resource (requires cert-manager) |
| server.certificate.issuer.group | string | `""` | Certificate issuer group. Set if using an external issuer. Eg. `cert-manager.io` |
| server.certificate.issuer.kind | string | `""` | Certificate issuer kind. Either `Issuer` or `ClusterIssuer` |
| server.certificate.issuer.name | string | `""` | Certificate isser name. Eg. `letsencrypt` |
| server.certificate.renewBefore | string | `""` | How long before the currently issued certificate's expiry cert-manager should renew the certificate. Value must be in units accepted by Go time.ParseDuration |
| server.certificate.secretName | string | `"argocd-server-tls"` | The name of the Secret that will be automatically created and managed by this Certificate resource |
| server.clusterAdminAccess.enabled | bool | `true` | Enable RBAC for local cluster deployments |
| server.config | object | See [values.yaml] | [General Argo CD configuration] |
| server.configAnnotations | object | `{}` | Annotations to be added to Argo CD ConfigMap |
| server.configEnabled | bool | `true` | Manage Argo CD configmap (Declarative Setup) |
| server.containerPort | int | `8080` | Configures the server port |
| server.containerSecurityContext | object | `{}` | Servers container-level security context |
| server.env | list | `[]` | Environment variables to pass to Argo CD server |
| server.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to Argo CD server |
| server.extensions.contents | list | `[]` | Extensions to be loaded into the server |
| server.extensions.enabled | bool | `false` | Enable support for extensions |
| server.extensions.image.imagePullPolicy | string | `"IfNotPresent"` | Image pull policy for extensions |
| server.extensions.image.repository | string | `"ghcr.io/argoproj-labs/argocd-extensions"` | Repository to use for extensions image |
| server.extensions.image.tag | string | `"v0.1.0"` | Tag to use for extensions image |
| server.extensions.resources | object | `{}` | Resource limits and requests for the argocd-extensions container |
| server.extraArgs | list | `[]` | Additional command line arguments to pass to Argo CD server |
| server.extraContainers | list | `[]` | Additional containers to be added to the server pod |
| server.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Argo CD server |
| server.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the Argo CD server |
| server.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Argo CD server |
| server.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
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
| server.initContainers | list | `[]` | Init containers to add to the server pod |
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
| server.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| server.metrics.service.servicePort | int | `8083` | Metrics service port |
| server.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| server.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| server.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| server.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| server.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| server.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| server.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| server.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| server.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| server.name | string | `"server"` | Argo CD server name |
| server.nodeSelector | object | `{}` | [Node selector] |
| server.pdb.annotations | object | `{}` | Annotations to be added to server pdb |
| server.pdb.enabled | bool | `false` | Deploy a Poddisruptionbudget for the server |
| server.pdb.labels | object | `{}` | Labels to be added to server pdb |
| server.podAnnotations | object | `{}` | Annotations to be added to server pods |
| server.podLabels | object | `{}` | Labels to be added to server pods |
| server.priorityClassName | string | `""` | Priority class for the Argo CD server |
| server.rbacConfig | object | `{}` | Argo CD rbac config ([Argo CD RBAC policy]) |
| server.rbacConfigAnnotations | object | `{}` | Annotations to be added to Argo CD rbac ConfigMap |
| server.rbacConfigCreate | bool | `true` | Whether or not to create the configmap. If false, it is expected the configmap will be created by something else. Argo CD will not work if there is no configMap created with the name above. |
| server.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| server.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| server.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| server.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| server.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| server.replicas | int | `1` | The number of server pods to run |
| server.resources | object | `{}` | Resource limits and requests for the Argo CD server |
| server.route.annotations | object | `{}` | Openshift Route annotations |
| server.route.enabled | bool | `false` | Enable an OpenShift Route for the Argo CD server |
| server.route.hostname | string | `""` | Hostname of OpenShift Route |
| server.route.termination_policy | string | `"None"` | Termination policy of Openshift Route |
| server.route.termination_type | string | `"passthrough"` | Termination type of Openshift Route |
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
| dex.extraArgs | list | `[]` | Additional command line arguments to pass to the Dex server |
| dex.extraContainers | list | `[]` | Additional containers to be added to the dex pod |
| dex.extraVolumeMounts | list | `[]` | Extra volumeMounts to the dex pod |
| dex.extraVolumes | list | `[]` | Extra volumes to the dex pod |
| dex.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Dex imagePullPolicy |
| dex.image.repository | string | `"ghcr.io/dexidp/dex"` | Dex image repository |
| dex.image.tag | string | `"v2.30.2"` | Dex image tag |
| dex.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| dex.initContainers | list | `[]` | Init containers to add to the dex pod |
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
| dex.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| dex.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| dex.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| dex.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| dex.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| dex.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| dex.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| dex.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| dex.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| dex.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| dex.name | string | `"dex-server"` | Dex name |
| dex.nodeSelector | object | `{}` | [Node selector] |
| dex.pdb.annotations | object | `{}` | Annotations to be added to Dex server pdb |
| dex.pdb.enabled | bool | `false` | Deploy a Poddisruptionbudget for the Dex server |
| dex.pdb.labels | object | `{}` | Labels to be added to Dex server pdb |
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

### Option 1 - Single Redis instance (default option)

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
| redis.image.tag | string | `"6.2.6-alpine"` | Redis tag |
| redis.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| redis.initContainers | list | `[]` | Init containers to add to the redis pod |
| redis.metrics.containerPort | int | `9121` | Port to use for redis-exporter sidecar |
| redis.metrics.enabled | bool | `false` | Deploy metrics service and redis-exporter sidecar |
| redis.metrics.image.imagePullPolicy | string | `"IfNotPresent"` | redis-exporter image PullPolicy |
| redis.metrics.image.repository | string | `"bitnami/redis-exporter"` | redis-exporter image repository |
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
| redis.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| redis.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| redis.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| redis.name | string | `"redis"` | Redis name |
| redis.nodeSelector | object | `{}` | [Node selector] |
| redis.pdb.annotations | object | `{}` | Annotations to be added to Redis server pdb |
| redis.pdb.enabled | bool | `false` | Deploy a Poddisruptionbudget for the Redis server |
| redis.pdb.labels | object | `{}` | Labels to be added to Redis server pdb |
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

### Option 2 - Redis HA

This option uses the following third-party chart to bootstrap a clustered Redis: https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha.
For all available configuration options, please read upstream README and/or chart source.
The main options are listed here:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis-ha.enabled | bool | `false` | Enables the Redis HA subchart and disables the custom Redis single node deployment |
| redis-ha.exporter.enabled | bool | `true` | If `true`, the prometheus exporter sidecar is enabled |
| redis-ha.exporter.image | string | `nil` (follows subchart default) | Exporter image |
| redis-ha.exporter.tag | string | `nil` (follows subchart default) | Exporter tag |
| redis-ha.haproxy.enabled | bool | `true` | Enabled HAProxy LoadBalancing/Proxy |
| redis-ha.haproxy.image.repository | string | `nil` (follows subchart default) | HAProxy Image Repository |
| redis-ha.haproxy.image.tag | string | `nil` (follows subchart default) | HAProxy Image Tag |
| redis-ha.haproxy.metrics.enabled | bool | `true` | HAProxy enable prometheus metric scraping |
| redis-ha.image.repository | string | `nil` (follows subchart default) | Redis image repository |
| redis-ha.image.tag | string | `"6.2.6-alpine"` | Redis tag |
| redis-ha.persistentVolume.enabled | bool | `false` | Configures persistency on Redis nodes |
| redis-ha.redis.config | object | See [values.yaml] | Any valid redis config options in this section will be applied to each server (see `redis-ha` chart) |
| redis-ha.redis.config.save | string | `'""'` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled |
| redis-ha.redis.masterGroupName | string | `"argocd"` | Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated |
| redis-ha.topologySpreadConstraints.enabled | bool | `false` | Enable Redis HA topology spread constraints |
| redis-ha.topologySpreadConstraints.maxSkew | string | `""` (defaults to `1`) | Max skew of pods tolerated |
| redis-ha.topologySpreadConstraints.topologyKey | string | `""` (defaults to `topology.kubernetes.io/zone`) | Topology key for spread |
| redis-ha.topologySpreadConstraints.whenUnsatisfiable | string | `""` (defaults to `ScheduleAnyway`) | Enforcement policy, hard or soft |

### Option 3 - External Redis

If you want to use an existing Redis (eg. a managed service from a cloud provider), you can use these parameters:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis credentials (must contain key `redis-password`). When it's set, the `externalRedis.password` parameter is ignored |
| externalRedis.host | string | `""` | External Redis server host |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.secretAnnotations | object | `{}` | External Redis Secret annotations |

## ApplicationSet

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| applicationSet.affinity | object | `{}` | Assign custom [affinity] rules |
| applicationSet.args.debug | bool | `false` | Print debug logs |
| applicationSet.args.dryRun | bool | `false` | Enable dry run mode |
| applicationSet.args.enableLeaderElection | bool | `false` | The default leader election setting |
| applicationSet.args.metricsAddr | string | `":8080"` | The default metric address |
| applicationSet.args.policy | string | `"sync"` | How application is synced between the generator and the cluster |
| applicationSet.args.probeBindAddr | string | `":8081"` | The default health check port |
| applicationSet.enabled | bool | `true` | Enable Application Set controller |
| applicationSet.extraArgs | list | `[]` | List of extra cli args to add |
| applicationSet.extraContainers | list | `[]` | Additional containers to be added to the applicationset controller pod |
| applicationSet.extraEnv | list | `[]` | Environment variables to pass to the controller |
| applicationSet.extraEnvFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the controller |
| applicationSet.extraVolumeMounts | list | `[]` | List of extra mounts to add (normally used with extraVolumes) |
| applicationSet.extraVolumes | list | `[]` | List of extra volumes to add |
| applicationSet.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the application set controller |
| applicationSet.image.repository | string | `"quay.io/argoproj/argocd-applicationset"` | Repository to use for the application set controller |
| applicationSet.image.tag | string | `"v0.4.1"` | Tag to use for the application set controller |
| applicationSet.imagePullSecrets | list | `[]` | If defined, uses a Secret to pull an image from a private Docker registry or repository. |
| applicationSet.metrics.enabled | bool | `false` | Deploy metrics service |
| applicationSet.metrics.service.annotations | object | `{}` | Metrics service annotations |
| applicationSet.metrics.service.labels | object | `{}` | Metrics service labels |
| applicationSet.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| applicationSet.metrics.service.servicePort | int | `8085` | Metrics service port |
| applicationSet.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| applicationSet.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| applicationSet.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| applicationSet.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| applicationSet.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| applicationSet.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| applicationSet.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| applicationSet.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| applicationSet.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| applicationSet.name | string | `"applicationset-controller"` | Application Set controller name string |
| applicationSet.nodeSelector | object | `{}` | [Node selector] |
| applicationSet.podAnnotations | object | `{}` | Annotations for the controller pods |
| applicationSet.podLabels | object | `{}` | Labels for the controller pods |
| applicationSet.podSecurityContext | object | `{}` | Pod Security Context |
| applicationSet.priorityClassName | string | `""` | If specified, indicates the pod's priority. If not specified, the pod priority will be default or zero if there is no default. |
| applicationSet.replicaCount | int | `1` | The number of controller pods to run |
| applicationSet.resources | object | `{}` | Resource limits and requests for the controller pods. |
| applicationSet.securityContext | object | `{}` | Security Context |
| applicationSet.service.annotations | object | `{}` | Application set service annotations |
| applicationSet.service.labels | object | `{}` | Application set service labels |
| applicationSet.service.port | int | `7000` | Application set service port |
| applicationSet.service.portName | string | `"webhook"` | Application set service port name |
| applicationSet.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| applicationSet.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| applicationSet.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| applicationSet.tolerations | list | `[]` | [Tolerations] for use with node taints |
| applicationSet.webhook.ingress.annotations | object | `{}` | Additional ingress annotations |
| applicationSet.webhook.ingress.enabled | bool | `false` | Enable an ingress resource for Webhooks |
| applicationSet.webhook.ingress.extraPaths | list | `[]` | Additional ingress paths |
| applicationSet.webhook.ingress.hosts | list | `[]` | List of ingress hosts |
| applicationSet.webhook.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| applicationSet.webhook.ingress.labels | object | `{}` | Additional ingress labels |
| applicationSet.webhook.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| applicationSet.webhook.ingress.paths | list | `["/api/webhook"]` | List of ingress paths |
| applicationSet.webhook.ingress.tls | list | `[]` | Ingress TLS configuration |

## Notifications

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| notifications.affinity | object | `{}` | Assign custom [affinity] rules |
| notifications.argocdUrl | string | `nil` | Argo CD dashboard url; used in place of {{.context.argocdUrl}} in templates |
| notifications.bots.slack.affinity | object | `{}` | Assign custom [affinity] rules |
| notifications.bots.slack.containerSecurityContext | object | `{}` | Container Security Context |
| notifications.bots.slack.enabled | bool | `false` | Enable slack bot |
| notifications.bots.slack.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Slack bot |
| notifications.bots.slack.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the Slack bot |
| notifications.bots.slack.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Slack bot |
| notifications.bots.slack.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| notifications.bots.slack.nodeSelector | object | `{}` | [Node selector] |
| notifications.bots.slack.resources | object | `{}` | Resource limits and requests for the Slack bot |
| notifications.bots.slack.securityContext | object | `{"runAsNonRoot":true}` | Pod Security Context |
| notifications.bots.slack.service.annotations | object | `{}` | Service annotations for Slack bot |
| notifications.bots.slack.service.port | int | `80` | Service port for Slack bot |
| notifications.bots.slack.service.type | string | `"LoadBalancer"` | Service type for Slack bot |
| notifications.bots.slack.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| notifications.bots.slack.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| notifications.bots.slack.serviceAccount.name | string | `"argocd-notifications-bot"` | The name of the service account to use. |
| notifications.bots.slack.tolerations | list | `[]` | [Tolerations] for use with node taints |
| notifications.bots.slack.updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |
| notifications.cm.create | bool | `true` | Whether helm chart creates controller config map |
| notifications.cm.name | string | `""` | The name of the config map to use. |
| notifications.containerSecurityContext | object | `{}` | Container Security Context |
| notifications.context | object | `{}` | Define user-defined context |
| notifications.enabled | bool | `true` | Enable Notifications controller |
| notifications.extraArgs | list | `[]` | Extra arguments to provide to the controller |
| notifications.extraEnv | list | `[]` | Additional container environment variables |
| notifications.extraVolumeMounts | list | `[]` | List of extra mounts to add (normally used with extraVolumes) |
| notifications.extraVolumes | list | `[]` | List of extra volumes to add |
| notifications.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the notifications controller |
| notifications.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the notifications controller |
| notifications.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the notifications controller |
| notifications.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| notifications.logFormat | string | `"text"` | Application controller log format. Either `text` or `json` |
| notifications.logLevel | string | `"info"` | Set the logging level. (One of: `debug`, `info`, `warn`, `error`) |
| notifications.metrics.enabled | bool | `false` | Enables prometheus metrics server |
| notifications.metrics.port | int | `9001` | Metrics port |
| notifications.metrics.service.annotations | object | `{}` | Metrics service annotations |
| notifications.metrics.service.labels | object | `{}` | Metrics service labels |
| notifications.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| notifications.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| notifications.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| notifications.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| notifications.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| notifications.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| notifications.name | string | `"notifications-controller"` | Notifications controller name string |
| notifications.nodeSelector | object | `{}` | [Node selector] |
| notifications.notifiers | object | See [values.yaml] | Configures notification services such as slack, email or custom webhook |
| notifications.podAnnotations | object | `{}` | Annotations to be applied to the controller Pods |
| notifications.podLabels | object | `{}` | Labels to be applied to the controller Pods |
| notifications.resources | object | `{}` | Resource limits and requests for the controller |
| notifications.secret.annotations | object | `{}` | key:value pairs of annotations to be added to the secret |
| notifications.secret.create | bool | `true` | Whether helm chart creates controller secret |
| notifications.secret.items | object | `{}` | Generic key:value pairs to be inserted into the secret |
| notifications.secret.name | string | `""` | The name of the secret to use. |
| notifications.securityContext | object | `{"runAsNonRoot":true}` | Pod Security Context |
| notifications.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| notifications.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| notifications.serviceAccount.name | string | `"argocd-notifications-controller"` | The name of the service account to use. |
| notifications.subscriptions | list | `[]` | Contains centrally managed global application subscriptions |
| notifications.templates | object | `{}` | The notification template is used to generate the notification content |
| notifications.tolerations | list | `[]` | [Tolerations] for use with node taints |
| notifications.triggers | object | `{}` | The trigger defines the condition when the notification should be sent |
| notifications.updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |

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
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[Argo CD RBAC policy]: https://argoproj.github.io/argo-cd/operator-manual/rbac/
[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[BackendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/concepts/backendconfig#backendconfigspec_v1beta1_cloudgooglecom
[CSS styles]: https://argo-cd.readthedocs.io/en/stable/operator-manual/custom-styles/
[external cluster credentials]: https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#clusters
[FrontendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features#configuring_ingress_features_through_frontendconfig_parameters
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
[v2.2 to 2.3 upgrade instructions]: https://github.com/argoproj/argo-cd/blob/v2.3.0/docs/operator-manual/upgrading/2.2-2.3.md
