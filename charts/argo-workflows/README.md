# Argo Workflows Chart

This is a **community maintained** chart. It is used to set up argo and its needed dependencies through one command. This is used in conjunction with [helm](https://github.com/kubernetes/helm).

If you want your deployment of this helm chart to most closely match the [argo CLI](https://github.com/argoproj/argo-workflows), you should deploy it in the `kube-system` namespace.

## Pre-Requisites

### Custom resource definitions

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--set crds.install=false` when installing the chart.

Helm cannot upgrade custom resource definitions in the `<chart>/crds` folder [by design](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations). Starting with 3.4.0 (chart version 0.19.0), the CRDs have been moved to `<chart>/templates` to address this design decision.

If you are using Argo Workflows chart version prior to 3.4.0 (chart version 0.19.0) or have elected to manage the Argo Workflows CRDs outside of the chart, please use `kubectl` to upgrade CRDs manually from [templates/crds](templates/crds/) folder or via the manifests from the upstream project repo:

```bash
kubectl apply -k "https://github.com/argoproj/argo-workflows/manifests/base/crds/full?ref=<appVersion>"

# Eg. version v3.3.9
kubectl apply -k "https://github.com/argoproj/argo-workflows/manifests/base/crds/full?ref=v3.3.9"
```

### ServiceAccount for Workflow Spec
In order for each Workflow run, you create ServiceAccount via `values.yaml` like below.

```yaml
workflow:
  serviceAccount:
    create: true
    name: "argo-workflow"
  rbac:
    create: true
controller:
  workflowNamespaces:
    - default
    - foo
    - bar
```

Set ServiceAccount on Workflow.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  entrypoint: whalesay
  serviceAccountName: argo-workflow # Set ServiceAccount
  templates:
    - name: whalesay
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "hello world" ]
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm install my-release argo/argo-workflows
NAME: my-release
...
```

## Changelog

For full list of changes, please check ArtifactHub [changelog].

## Usage Notes

### Workflow controller

This chart defaults to setting the `controller.instanceID.enabled` to `false` now, which means the deployed controller will act upon any workflow deployed to the cluster. If you would like to limit the behavior and deploy multiple workflow controllers, please use the `controller.instanceID.enabled` attribute along with one of its configuration options to set the `instanceID` of the workflow controller to be properly scoped for your needs.

### Workflow server authentication

By default, the chart requires some kind of authentication mechanism. This adopts the [default behaviour from the Argo project](https://github.com/argoproj/argo-workflows/pull/5211) itself. However, for local development purposes, or cases where your gateway authentication is covered by some other means, you can set the authentication mode for the Argo server by setting the `server.extraArgs: [--auth-mode=server]`. There are a few additional comments in the values.yaml file itself, including commented-out settings to disable authentication on the server UI itself using the same `--auth-mode=server` setting.

## Values

The `values.yaml` contains items used to tweak a deployment of this chart.
Fields to note:

- `controller.instanceID.enabled`: If set to true, the Argo Controller will **ONLY** monitor Workflow submissions with a `--instanceid` attribute
- `controller.instanceID.useReleaseName`: If set to true then chart set controller instance id to release name
- `controller.instanceID.explicitID`: Allows customization of an instance id for the workflow controller to monitor
- `singleNamespace`:  When true, restricts the workflow controller to operate
  in just the single namespace (that one of the Helm release).
- `controller.workflowNamespaces`: This is a list of namespaces where the
  workflow controller will manage workflows. Only valid when `singleNamespace`
  is false.

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersionOverrides.autoscaling | string | `""` | String to override apiVersion of autoscaling rendered by this helm chart |
| apiVersionOverrides.cloudgoogle | string | `""` | String to override apiVersion of GKE resources rendered by this helm chart |
| crds.annotations | object | `{}` | Annotations to be added to all CRDs |
| crds.install | bool | `true` | Install and upgrade CRDs |
| crds.keep | bool | `true` | Keep CRDs on chart uninstall |
| createAggregateRoles | bool | `true` | Create clusterroles that extend existing clusterroles to interact with argo-cd crds |
| emissary.images | list | `[]` | The command/args for each image on workflow, needed when the command is not specified and the emissary executor is used. |
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| fullnameOverride | string | `nil` | String to fully override "argo-workflows.fullname" template |
| images.pullPolicy | string | `"Always"` | imagePullPolicy to apply to all containers |
| images.pullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| images.tag | string | `""` | Common tag for Argo Workflows images. Defaults to `.Chart.AppVersion`. |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `nil` | String to partially override "argo-workflows.fullname" template |
| singleNamespace | bool | `false` | Restrict Argo to operate only in a single namespace (the namespace of the Helm release) by apply Roles and RoleBindings instead of the Cluster equivalents, and start workflow-controller with the --namespaced flag. Use it in clusters with strict access policy. |

### Workflow

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workflow.namespace | string | `nil` | Deprecated; use controller.workflowNamespaces instead. |
| workflow.rbac.create | bool | `true` | Adds Role and RoleBinding for the above specified service account to be able to run workflows. A Role and Rolebinding pair is also created for each namespace in controller.workflowNamespaces (see below) |
| workflow.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| workflow.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| workflow.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| workflow.serviceAccount.name | string | `"argo-workflow"` | Service account which is used to run workflows |

### Workflow Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` | Assign custom [affinity] rules |
| controller.clusterWorkflowTemplates.enabled | bool | `true` | Create a ClusterRole and CRB for the controller to access ClusterWorkflowTemplates. |
| controller.columns | list | `[]` | Configure Argo Server to show custom [columns] |
| controller.deploymentAnnotations | object | `{}` | deploymentAnnotations is an optional map of annotations to be applied to the controller Deployment |
| controller.extraArgs | list | `[]` | Extra arguments to be added to the controller |
| controller.extraContainers | list | `[]` | Extra containers to be added to the controller deployment |
| controller.extraEnv | list | `[]` | Extra environment variables to provide to the controller container |
| controller.extraInitContainers | list | `[]` | Enables init containers to be added to the controller deployment |
| controller.image.registry | string | `"quay.io"` | Registry to use for the controller |
| controller.image.repository | string | `"argoproj/workflow-controller"` | Registry to use for the controller |
| controller.image.tag | string | `""` | Image tag for the workflow controller. Defaults to `.Values.images.tag`. |
| controller.initialDelay | string | `nil` | Resolves ongoing, uncommon AWS EKS bug: https://github.com/argoproj/argo-workflows/pull/4224 |
| controller.instanceID.enabled | bool | `false` | Configures the controller to filter workflow submissions to only those which have a matching instanceID attribute. |
| controller.instanceID.explicitID | string | `""` | Use a custom instanceID |
| controller.instanceID.useReleaseName | bool | `false` | Use ReleaseName as instanceID |
| controller.kubeConfig | object | `{}` (See [values.yaml]) | Configure when workflow controller runs in a different k8s cluster with the workflow workloads, or needs to communicate with the k8s apiserver using an out-of-cluster kubeconfig secret. |
| controller.links | list | `[]` | Configure Argo Server to show custom [links] |
| controller.livenessProbe | object | See [values.yaml] | Configure liveness [probe] for the controller |
| controller.loadBalancerSourceRanges | list | `[]` | Source ranges to allow access to service from. Only applies to service type `LoadBalancer` |
| controller.logging.format | string | `"text"` | Set the logging format (one of: `text`, `json`) |
| controller.logging.globallevel | string | `"0"` | Set the glog logging level |
| controller.logging.level | string | `"info"` | Set the logging level (one of: `debug`, `info`, `warn`, `error`) |
| controller.metricsConfig.enabled | bool | `false` | Enables prometheus metrics server |
| controller.metricsConfig.ignoreErrors | bool | `false` | Flag that instructs prometheus to ignore metric emission errors. |
| controller.metricsConfig.metricRelabelings | list | `[]` | ServiceMonitor metric relabel configs to apply to samples before ingestion |
| controller.metricsConfig.metricsTTL | string | `""` | How often custom metrics are cleared from memory |
| controller.metricsConfig.path | string | `"/metrics"` | Path is the path where metrics are emitted. Must start with a "/". |
| controller.metricsConfig.port | int | `9090` | Port is the port where metrics are emitted |
| controller.metricsConfig.portName | string | `"metrics"` | Container metrics port name |
| controller.metricsConfig.relabelings | list | `[]` | ServiceMonitor relabel configs to apply to samples before scraping |
| controller.metricsConfig.secure | bool | `false` | Flag that use a self-signed cert for TLS |
| controller.metricsConfig.servicePort | int | `8080` | Service metrics port |
| controller.metricsConfig.servicePortName | string | `"metrics"` | Service metrics port name |
| controller.metricsConfig.targetLabels | list | `[]` | ServiceMonitor will add labels from the service to the Prometheus metric |
| controller.name | string | `"workflow-controller"` | Workflow controller name string |
| controller.namespaceParallelism | string | `nil` | Limits the maximum number of incomplete workflows in a namespace |
| controller.navColor | string | `""` | Set ui navigation bar background color |
| controller.nodeEvents.enabled | bool | `true` | Enable to emit events on node completion. |
| controller.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | [Node selector] |
| controller.parallelism | string | `nil` | parallelism dictates how many workflows can be running at the same time |
| controller.pdb.enabled | bool | `false` | Configure [Pod Disruption Budget] for the controller pods |
| controller.persistence | object | `{}` | enable persistence using postgres |
| controller.podAnnotations | object | `{}` | podAnnotations is an optional map of annotations to be applied to the controller Pods |
| controller.podGCDeleteDelayDuration | string | `5s` (Argo Workflows default) | The duration in seconds before the pods in the GC queue get deleted. A zero value indicates that the pods will be deleted immediately. |
| controller.podGCGracePeriodSeconds | string | `30` seconds (Kubernetes default) | Specifies the duration in seconds before a terminating pod is forcefully killed. A zero value indicates that the pod will be forcefully terminated immediately. |
| controller.podLabels | object | `{}` | Optional labels to add to the controller pods |
| controller.podSecurityContext | object | `{}` | SecurityContext to set on the controller pods |
| controller.priorityClassName | string | `""` | Leverage a PriorityClass to ensure your pods survive resource shortages. |
| controller.rbac.accessAllSecrets | bool | `false` | Allows controller to get, list and watch all k8s secrets. Can only be used if secretWhitelist is empty. |
| controller.rbac.create | bool | `true` | Adds Role and RoleBinding for the controller. |
| controller.rbac.secretWhitelist | list | `[]` | Allows controller to get, list, and watch certain k8s secrets |
| controller.rbac.writeConfigMaps | bool | `false` | Allows controller to create and update ConfigMaps. Enables memoization feature |
| controller.replicas | int | `1` | The number of controller pods to run |
| controller.resourceRateLimit | object | `{}` | Globally limits the rate at which pods are created. This is intended to mitigate flooding of the Kubernetes API server by workflows with a large amount of parallel nodes. |
| controller.resources | object | `{}` | Resource limits and requests for the controller |
| controller.retentionPolicy | object | `{}` | Workflow retention by number of workflows |
| controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | the controller container's securityContext |
| controller.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| controller.serviceAccount.create | bool | `true` | Create a service account for the controller |
| controller.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| controller.serviceAccount.name | string | `""` | Service account name |
| controller.serviceAnnotations | object | `{}` | Annotations to be applied to the controller Service |
| controller.serviceLabels | object | `{}` | Optional labels to add to the controller Service |
| controller.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| controller.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| controller.serviceType | string | `"ClusterIP"` | Service type of the controller Service |
| controller.telemetryConfig.enabled | bool | `false` | Enables prometheus telemetry server |
| controller.telemetryConfig.ignoreErrors | bool | `false` | Flag that instructs prometheus to ignore metric emission errors. |
| controller.telemetryConfig.metricsTTL | string | `""` | How often custom metrics are cleared from memory |
| controller.telemetryConfig.path | string | `"/telemetry"` | telemetry path |
| controller.telemetryConfig.port | int | `8081` | telemetry container port |
| controller.telemetryConfig.secure | bool | `false` | Flag that use a self-signed cert for TLS |
| controller.telemetryConfig.servicePort | int | `8081` | telemetry service port |
| controller.telemetryConfig.servicePortName | string | `"telemetry"` | telemetry service port name |
| controller.tolerations | list | `[]` | [Tolerations] for use with node taints |
| controller.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the workflow controller |
| controller.volumeMounts | list | `[]` | Additional volume mounts to the controller main container |
| controller.volumes | list | `[]` | Additional volumes to the controller pod |
| controller.workflowDefaults | object | `{}` | Default values that will apply to all Workflows from this controller, unless overridden on the Workflow-level. Only valid for 2.7+ |
| controller.workflowNamespaces | list | `["default"]` | Specify all namespaces where this workflow controller instance will manage workflows. This controls where the service account and RBAC resources will be created. Only valid when singleNamespace is false. |
| controller.workflowRestrictions | object | `{}` | Restricts the Workflows that the controller will process. Only valid for 2.9+ |
| controller.workflowWorkers | string | `nil` | Number of workflow workers |

### Workflow Main Container

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mainContainer.env | list | `[]` | Adds environment variables for the Workflow main container |
| mainContainer.envFrom | list | `[]` | Adds reference environment variables for the Workflow main container |
| mainContainer.imagePullPolicy | string | `""` | imagePullPolicy to apply to Workflow main container. Defaults to `.Values.images.pullPolicy`. |
| mainContainer.resources | object | `{}` | Resource limits and requests for the Workflow main container |
| mainContainer.securityContext | object | `{}` | sets security context for the Workflow main container |

### Workflow Executor

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| executor.env | list | `[]` | Adds environment variables for the executor. |
| executor.image.pullPolicy | string | `""` | Image PullPolicy to use for the Workflow Executors. Defaults to `.Values.images.pullPolicy`. |
| executor.image.registry | string | `"quay.io"` | Registry to use for the Workflow Executors |
| executor.image.repository | string | `"argoproj/argoexec"` | Repository to use for the Workflow Executors |
| executor.image.tag | string | `""` | Image tag for the workflow executor. Defaults to `.Values.images.tag`. |
| executor.resources | object | `{}` | Resource limits and requests for the Workflow Executors |
| executor.securityContext | object | `{}` | sets security context for the executor container |

### Workflow Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server.GKEbackendConfig.enabled | bool | `false` | Enable BackendConfig custom resource for Google Kubernetes Engine |
| server.GKEbackendConfig.spec | object | `{}` | [BackendConfigSpec] |
| server.GKEfrontendConfig.enabled | bool | `false` | Enable FrontConfig custom resource for Google Kubernetes Engine |
| server.GKEfrontendConfig.spec | object | `{}` | [FrontendConfigSpec] |
| server.GKEmanagedCertificate.domains | list | `["argoworkflows.example.com"]` | Domains for the Google Managed Certificate |
| server.GKEmanagedCertificate.enabled | bool | `false` | Enable ManagedCertificate custom resource for Google Kubernetes Engine. |
| server.affinity | object | `{}` | Assign custom [affinity] rules |
| server.autoscaling.behavior | object | `{}` | Configures the scaling behavior of the target in both Up and Down directions. This is only available on HPA apiVersion `autoscaling/v2beta2` and newer |
| server.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the Argo Server |
| server.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the Argo Server [HPA] |
| server.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the Argo Server [HPA] |
| server.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the Argo Server [HPA] |
| server.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the Argo Server [HPA] |
| server.baseHref | string | `"/"` | Value for base href in index.html. Used if the server is running behind reverse proxy under subpath different from /. |
| server.clusterWorkflowTemplates.enableEditing | bool | `true` | Give the server permissions to edit ClusterWorkflowTemplates. |
| server.clusterWorkflowTemplates.enabled | bool | `true` | Create a ClusterRole and CRB for the server to access ClusterWorkflowTemplates. |
| server.deploymentAnnotations | object | `{}` | optional map of annotations to be applied to the ui Deployment |
| server.enabled | bool | `true` | Deploy the Argo Server |
| server.extraArgs | list | `[]` | Extra arguments to provide to the Argo server binary, such as for disabling authentication. |
| server.extraContainers | list | `[]` | Extra containers to be added to the server deployment |
| server.extraEnv | list | `[]` | Extra environment variables to provide to the argo-server container |
| server.extraInitContainers | list | `[]` | Enables init containers to be added to the server deployment |
| server.image.registry | string | `"quay.io"` | Registry to use for the server |
| server.image.repository | string | `"argoproj/argocli"` | Repository to use for the server |
| server.image.tag | string | `""` | Image tag for the Argo Workflows server. Defaults to `.Values.images.tag`. |
| server.ingress.annotations | object | `{}` | Additional ingress annotations |
| server.ingress.enabled | bool | `false` | Enable an ingress resource |
| server.ingress.extraPaths | list | `[]` | Additional ingress paths |
| server.ingress.hosts | list | `[]` | List of ingress hosts |
| server.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| server.ingress.labels | object | `{}` | Additional ingress labels |
| server.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| server.ingress.paths | list | `["/"]` | List of ingress paths |
| server.ingress.tls | list | `[]` | Ingress TLS configuration |
| server.loadBalancerIP | string | `""` | Static IP address to assign to loadBalancer service type `LoadBalancer` |
| server.loadBalancerSourceRanges | list | `[]` | Source ranges to allow access to service from. Only applies to service type `LoadBalancer` |
| server.logging.format | string | `"text"` | Set the logging format (one of: `text`, `json`) |
| server.logging.globallevel | string | `"0"` | Set the glog logging level |
| server.logging.level | string | `"info"` | Set the logging level (one of: `debug`, `info`, `warn`, `error`) |
| server.name | string | `"server"` | Server name string |
| server.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | [Node selector] |
| server.pdb.enabled | bool | `false` | Configure [Pod Disruption Budget] for the server pods |
| server.podAnnotations | object | `{}` | optional map of annotations to be applied to the ui Pods |
| server.podLabels | object | `{}` | Optional labels to add to the UI pods |
| server.podSecurityContext | object | `{}` | SecurityContext to set on the server pods |
| server.priorityClassName | string | `""` | Leverage a PriorityClass to ensure your pods survive resource shortages |
| server.rbac.create | bool | `true` | Adds Role and RoleBinding for the server. |
| server.replicas | int | `1` | The number of server pods to run |
| server.resources | object | `{}` | Resource limits and requests for the server |
| server.secure | bool | `false` | Run the argo server in "secure" mode. Configure this value instead of `--secure` in extraArgs. |
| server.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsNonRoot":true}` | Servers container-level security context |
| server.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| server.serviceAccount.create | bool | `true` | Create a service account for the server |
| server.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| server.serviceAccount.name | string | `""` | Service account name |
| server.serviceAnnotations | object | `{}` | Annotations to be applied to the UI Service |
| server.serviceLabels | object | `{}` | Optional labels to add to the UI Service |
| server.serviceNodePort | string | `nil` | Service node port |
| server.servicePort | int | `2746` | Service port for server |
| server.servicePortName | string | `""` | Service port name |
| server.serviceType | string | `"ClusterIP"` | Service type for server pods |
| server.sso.clientId.key | string | `"client-id"` | Key of secret to retrieve the app OIDC client ID |
| server.sso.clientId.name | string | `"argo-server-sso"` | Name of secret to retrieve the app OIDC client ID |
| server.sso.clientSecret.key | string | `"client-secret"` | Key of a secret to retrieve the app OIDC client secret |
| server.sso.clientSecret.name | string | `"argo-server-sso"` | Name of a secret to retrieve the app OIDC client secret |
| server.sso.customGroupClaimName | string | `""` | Override claim name for OIDC groups |
| server.sso.enabled | bool | `false` | Create SSO configuration |
| server.sso.insecureSkipVerify | bool | `false` | Skip TLS verification for the HTTP client |
| server.sso.issuer | string | `"https://accounts.google.com"` | The root URL of the OIDC identity provider |
| server.sso.issuerAlias | string | `""` | Alternate root URLs that can be included for some OIDC providers |
| server.sso.rbac.enabled | bool | `true` | Adds ServiceAccount Policy to server (Cluster)Role. |
| server.sso.rbac.secretWhitelist | list | `[]` | Whitelist to allow server to fetch Secrets |
| server.sso.redirectUrl | string | `"https://argo/oauth2/callback"` |  |
| server.sso.scopes | list | `[]` | Scopes requested from the SSO ID provider |
| server.sso.sessionExpiry | string | `""` | Define how long your login is valid for (in hours) |
| server.sso.userInfoPath | string | `""` | Specify the user info endpoint that contains the groups claim |
| server.tolerations | list | `[]` | [Tolerations] for use with node taints |
| server.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the argo server |
| server.volumeMounts | list | `[]` | Additional volume mounts to the server main container. |
| server.volumes | list | `[]` | Additional volumes to the server pod. |

### Artifact Repository

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| artifactRepository.archiveLogs | bool | `false` | Archive the main container logs as an artifact |
| artifactRepository.azure | object | `{}` (See [values.yaml]) | Store artifact in Azure Blob Storage |
| artifactRepository.gcs | object | `{}` (See [values.yaml]) | Store artifact in a GCS object store |
| artifactRepository.s3 | object | See [values.yaml] | Store artifact in a S3-compliant object store |
| customArtifactRepository | object | `{}` | The section of custom artifact repository. Utilize a custom artifact repository that is not one of the current base ones (s3, gcs, azure) |
| useStaticCredentials | bool | `true` | Use static credentials for S3 (eg. when not using AWS IRSA) |

## Breaking changes from the deprecated `argo` chart

1. the `installCRD` value has been removed. CRDs are now only installed from the conventional crds/ directory
1. the CRDs were updated to `apiextensions.k8s.io/v1`
1. the container image registry/project/tag format was changed to be more in line with the more common

   ```yaml
   image:
     registry: quay.io
     repository: argoproj/argocli
     tag: v3.0.1
   ```

   this also makes it easier for automatic update tooling (eg. renovate bot) to detect and update images.

1. switched to quay.io as the default registry for all images
1. removed any included usage of Minio
1. aligned the configuration of serviceAccounts with the argo-cd chart, ie: what used to be `server.createServiceAccount` is now `server.serviceAccount.create`
1. moved the field previously known as `telemetryServicePort` inside the `telemetryConfig` as `telemetryConfig.servicePort` - same for `metricsConfig`

[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[BackendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/concepts/backendconfig#backendconfigspec_v1beta1_cloudgooglecom
[FrontendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features#configuring_ingress_features_through_frontendconfig_parameters
[links]: https://argoproj.github.io/argo-workflows/links/
[columns]: https://github.com/argoproj/argo-workflows/pull/10693
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[Pod Disruption Budget]: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[TopologySpreadConstraints]: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
[values.yaml]: values.yaml
[changelog]: https://artifacthub.io/packages/helm/argo/argo-workflows?modal=changelog
