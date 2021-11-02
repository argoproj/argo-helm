# Argo Workflows Chart

This is a **community maintained** chart. It is used to set up argo and it's needed dependencies through one command. This is used in conjunction with [helm](https://github.com/kubernetes/helm).

If you want your deployment of this helm chart to most closely match the [argo CLI](https://github.com/argoproj/argo-workflows), you should deploy it in the `kube-system` namespace.

## Pre-Requisites

This chart uses an install hook to configure the CRD definition. Installation of CRDs is a somewhat privileged process in itself and in RBAC enabled clusters the `default` service account for namespaces does not typically have the ability to do create these.

A few options are:

- Manually create a ServiceAccount in the Namespace which your release will be deployed w/ appropriate bindings to perform this action and set the `serviceAccountName` field in the Workflow spec
- Augment the `default` ServiceAccount permissions in the Namespace in which your Release is deployed to have the appropriate permissions

## Usage Notes

This chart defaults to setting the `controller.instanceID.enabled` to `false` now, which means the deployed controller will act upon any workflow deployed to the cluster. If you would like to limit the behavior and deploy multiple workflow controllers, please use the `controller.instanceID.enabled` attribute along with one of it's configuration options to set the `instanceID` of the workflow controller to be properly scoped for your needs.

## General parameters

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
 

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| createAggregateRoles | bool | `true` |  |
| fullnameOverride | string | `nil` | String to fully override "argo-workflows.fullname" template |
| images.pullPolicy | string | `"Always"` | imagePullPolicy to apply to all containers |
| images.pullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `nil` | String to partially override "argo-workflows.fullname" template |
| singleNamespace | bool | `false` | Restrict Argo to operate only in a single namespace (the namespace of the Helm release) by apply Roles and RoleBindings instead of the Cluster equivalents, and start workflow-controller with the --namespaced flag. Use it in clusters with strict access policy. |
| useDefaultArtifactRepo | bool | `false` | Influences the creation of the ConfigMap for the workflow-controller itself. |
| useStaticCredentials | bool | `true` |  |

## Workflow

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workflow.namespace | string | `nil` | Deprecated; use controller.workflowNamespaces instead. |
| workflow.rbac.create | bool | `true` | Adds Role and RoleBinding for the above specified service account to be able to run workflows. A Role and Rolebinding pair is also created for each namespace in controller.workflowNamespaces (see below) |
| workflow.serviceAccount.annotations | object | `{}` |  |
| workflow.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| workflow.serviceAccount.name | string | `"argo-workflow"` | Service account which is used to run workflows |

## Workflow Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` |  |
| controller.clusterWorkflowTemplates.enabled | bool | `true` | Create a ClusterRole and CRB for the controller to access ClusterWorkflowTemplates. |
| controller.containerRuntimeExecutor | string | `"docker"` |  |
| controller.extraArgs | list | `[]` | Extra arguments to be added to the controller |
| controller.extraContainers | list | `[]` | Extra containers to be added to the controller deployment |
| controller.extraEnv | list | `[]` | Extra environment variables to provide to the controller container |
| controller.image.registry | string | `"quay.io"` |  |
| controller.image.repository | string | `"argoproj/workflow-controller"` |  |
| controller.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| controller.initialDelay | string | `nil` | Resolves ongoing, uncommon AWS EKS bug: https://github.com/argoproj/argo-workflows/pull/4224 |
| controller.instanceID.enabled | bool | `false` | `instanceID.enabled` configures the controller to filter workflow submissions to only those which have a matching instanceID attribute. |
| controller.links | list | `[]` |  |
| controller.livenessProbe.failureThreshold | int | `3` | Require three failures to tolerate transient errors. |
| controller.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| controller.livenessProbe.httpGet.port | int | `6060` |  |
| controller.livenessProbe.initialDelaySeconds | int | `90` |  |
| controller.livenessProbe.periodSeconds | int | `60` |  |
| controller.livenessProbe.timeoutSeconds | int | `30` |  |
| controller.loadBalancerSourceRanges | list | `[]` | Source ranges to allow access to service from. Only applies to service type `LoadBalancer` |
| controller.logging.globallevel | string | `"0"` |  |
| controller.logging.level | string | `"info"` |  |
| controller.metricsConfig.enabled | bool | `false` |  |
| controller.metricsConfig.path | string | `"/metrics"` |  |
| controller.metricsConfig.port | int | `9090` |  |
| controller.metricsConfig.portName | string | `"metrics"` |  |
| controller.metricsConfig.servicePort | int | `8080` |  |
| controller.metricsConfig.servicePortName | string | `"metrics"` |  |
| controller.name | string | `"workflow-controller"` |  |
| controller.namespaceParallelism | string | `nil` | Limits the maximum number of incomplete workflows in a namespace |
| controller.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node selectors and tolerations for server scheduling to nodes with taints |
| controller.parallelism | string | `nil` | parallelism dictates how many workflows can be running at the same time |
| controller.pdb.enabled | bool | `false` |  |
| controller.persistence | object | `{}` |  |
| controller.podAnnotations | object | `{}` | podAnnotations is an optional map of annotations to be applied to the controller Pods |
| controller.podLabels | object | `{}` | Optional labels to add to the controller pods |
| controller.podSecurityContext | object | `{}` | SecurityContext to set on the controller pods |
| controller.priorityClassName | string | `""` | Leverage a PriorityClass to ensure your pods survive resource shortages. ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ PriorityClass: system-cluster-critical |
| controller.replicas | int | `1` |  |
| controller.resources | object | `{}` |  |
| controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | the controller container's securityContext |
| controller.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| controller.serviceAccount.create | bool | `true` |  |
| controller.serviceAccount.name | string | `""` |  |
| controller.serviceAnnotations | object | `{}` | Annotations to be applied to the controller Service |
| controller.serviceLabels | object | `{}` | Optional labels to add to the controller Service |
| controller.serviceMonitor.additionalLabels | object | `{}` |  |
| controller.serviceMonitor.enabled | bool | `false` |  |
| controller.serviceType | string | `"ClusterIP"` |  |
| controller.telemetryConfig.enabled | bool | `false` |  |
| controller.telemetryConfig.path | string | `"/telemetry"` |  |
| controller.telemetryConfig.port | int | `8081` |  |
| controller.telemetryConfig.servicePort | int | `8081` |  |
| controller.telemetryConfig.servicePortName | string | `"telemetry"` |  |
| controller.tolerations | list | `[]` |  |
| controller.workflowDefaults | object | `{}` |  |
| controller.workflowNamespaces | list | `["default"]` | Specify all namespaces where this workflow controller instance will manage workflows. This controls where the service account and RBAC resources will be created. Only valid when singleNamespace is false. |
| controller.workflowRestrictions | object | `{}` |  |

## Workflow Executor

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| executor.env | object | `{}` | Adds environment variables for the executor. |
| executor.image.registry | string | `"quay.io"` |  |
| executor.image.repository | string | `"argoproj/argoexec"` |  |
| executor.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| executor.resources | object | `{}` |  |
| executor.securityContext | object | `{}` | sets security context for the executor container |

## Workflow Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server.affinity | object | `{}` |  |
| server.baseHref | string | `"/"` | only updates base url of resources on client side, it's expected that a proxy server rewrites the request URL and gets rid of this prefix https://github.com/argoproj/argo-workflows/issues/716#issuecomment-433213190 |
| server.clusterWorkflowTemplates.enableEditing | bool | `true` | Give the server permissions to edit ClusterWorkflowTemplates. |
| server.clusterWorkflowTemplates.enabled | bool | `true` | Create a ClusterRole and CRB for the server to access ClusterWorkflowTemplates. |
| server.enabled | bool | `true` |  |
| server.extraArgs | list | `[]` | Extra arguments to provide to the Argo server binary. |
| server.extraContainers | list | `[]` |  |
| server.extraEnv | list | `[]` | Extra environment variables to provide to the argo-server container |
| server.image.registry | string | `"quay.io"` |  |
| server.image.repository | string | `"argoproj/argocli"` |  |
| server.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| server.ingress | object | `{"annotations":{},"enabled":false,"extraPaths":[],"hosts":[],"https":false,"ingressClassName":"","labels":{},"pathType":"Prefix","paths":["/"],"tls":[]}` | Ingress configuration. ref: https://kubernetes.io/docs/user-guide/ingress/ |
| server.ingress.hosts | list | `[]` | Argo Workflows Server Ingress. Hostnames must be provided if Ingress is enabled. Secrets must be manually created in the namespace |
| server.loadBalancerIP | string | `""` | Static IP address to assign to loadBalancer service type `LoadBalancer` |
| server.loadBalancerSourceRanges | list | `[]` | Source ranges to allow access to service from. Only applies to service type `LoadBalancer` |
| server.name | string | `"server"` |  |
| server.nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Node selectors and tolerations for server scheduling to nodes with taints. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ |
| server.pdb.enabled | bool | `false` |  |
| server.podAnnotations | object | `{}` | optional map of annotations to be applied to the ui Pods |
| server.podLabels | object | `{}` | Optional labels to add to the UI pods |
| server.podSecurityContext | object | `{}` | SecurityContext to set on the server pods |
| server.priorityClassName | string | `""` | Leverage a PriorityClass to ensure your pods survive resource shortages ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ PriorityClass: system-cluster-critical |
| server.replicas | int | `1` |  |
| server.resources | object | `{}` |  |
| server.secure | bool | `false` | Run the argo server in "secure" mode. Configure this value instead of "--secure" in extraArgs. See the following documentation for more details on secure mode: https://argoproj.github.io/argo-workflows/tls/ |
| server.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| server.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| server.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| server.securityContext.runAsNonRoot | bool | `true` |  |
| server.serviceAccount.annotations | object | `{}` |  |
| server.serviceAccount.create | bool | `true` |  |
| server.serviceAccount.name | string | `""` |  |
| server.serviceAnnotations | object | `{}` | Annotations to be applied to the UI Service |
| server.serviceLabels | object | `{}` | Optional labels to add to the UI Service |
| server.servicePort | int | `2746` |  |
| server.serviceType | string | `"ClusterIP"` |  |
| server.sso | string | `nil` |  |
| server.tolerations | list | `[]` |  |
| server.volumeMounts | list | `[]` | Additional volumes to the server main container. |
| server.volumes | list | `[]` |  |

## Artifact Repository

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| artifactRepository.archiveLogs | bool | `false` | archiveLogs will archive the main container logs as an artifact |
| artifactRepository.s3.accessKeySecret.key | string | `"accesskey"` |  |
| artifactRepository.s3.insecure | bool | `true` |  |
| artifactRepository.s3.secretKeySecret.key | string | `"secretkey"` |  |

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
1. moved the previously known as `telemetryServicePort` inside the `telemetryConfig` as `telemetryConfig.servicePort` - same for `metricsConfig`
