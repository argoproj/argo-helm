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

### UI Dashboard

If dashboard is installed by `--set dashboard.enabled=true`, checkout the argo-rollouts dashboard by
`kubectl port-forward service/argo-rollouts-dashboard 31000:3100` and pointing the browser to `localhost:31000`

| :warning: WARNING when the Service type is set to LoadBalancer or NodePort |
|:---------------------------------------------------------------------------|
| The chart provides an option to change the service type (`dashboard.service.type`). Also it provides the ability to expose the dashboard via Ingress. Dashboard was never intended to be exposed as an administrative console -- it started out as a local view available via CLI. It should be protected by something (e.g. network access or even better an oauth proxy). |

## Changelog

For full list of changes please check ArtifactHub [changelog].

## Chart Values

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersionOverrides.ingress | string | `""` | String to override apiVersion of ingresses rendered by this helm chart |
| clusterInstall | bool | `true` | `false` runs controller in namespaced mode (does not require cluster RBAC) |
| crdAnnotations | object | `{}` | Annotations to be added to all CRDs |
| createClusterAggregateRoles | bool | `true` | flag to enable creation of cluster aggregate roles (requires cluster RBAC) |
| extraObjects | list | `[]` | Additional manifests to deploy within the chart. A list of objects. |
| fullnameOverride | string | `nil` | String to fully override "argo-rollouts.fullname" template |
| global.deploymentAnnotations | object | `{}` | Annotations for all deployed Deployments |
| imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry. Registry secret names as an array. |
| installCRDs | bool | `true` | Install and upgrade CRDs |
| keepCRDs | bool | `true` | Keep CRD's on helm uninstall |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `nil` | String to partially override "argo-rollouts.fullname" template |
| notifications.notifiers | object | `{}` | Configures notification services |
| notifications.secret.create | bool | `false` | Whether to create notifications secret |
| notifications.secret.items | object | `{}` | Generic key:value pairs to be inserted into the notifications secret |
| notifications.templates | object | `{}` | Notification templates |
| notifications.triggers | object | `{}` | The trigger defines the condition when the notification should be sent |
| providerRBAC.enabled | bool | `true` | Toggles addition of provider-specific RBAC rules to the controller Role and ClusterRole |
| providerRBAC.providers.ambassador | bool | `true` | Adds RBAC rules for the Ambassador provider |
| providerRBAC.providers.apisix | bool | `true` | Adds RBAC rules for the Apisix provider |
| providerRBAC.providers.awsAppMesh | bool | `true` | Adds RBAC rules for the AWS App Mesh provider |
| providerRBAC.providers.awsLoadBalancerController | bool | `true` | Adds RBAC rules for the AWS Load Balancer Controller provider |
| providerRBAC.providers.contour | bool | `true` | Adds RBAC rules for the Contour provider, see `https://github.com/argoproj-labs/rollouts-plugin-trafficrouter-contour/blob/main/README.md` |
| providerRBAC.providers.glooPlatform | bool | `true` | Adds RBAC rules for the Gloo Platform provider, see `https://github.com/argoproj-labs/rollouts-plugin-trafficrouter-glooplatform/blob/main/README.md` |
| providerRBAC.providers.istio | bool | `true` | Adds RBAC rules for the Istio provider |
| providerRBAC.providers.smi | bool | `true` | Adds RBAC rules for the SMI provider |
| providerRBAC.providers.traefik | bool | `true` | Adds RBAC rules for the Traefik provider |

### Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext | object | `{}` | Security Context to set on container level |
| controller.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| controller.component | string | `"rollouts-controller"` | Value of label `app.kubernetes.io/component` |
| controller.containerPorts.healthz | int | `8080` | Healthz container port |
| controller.containerPorts.metrics | int | `8090` | Metrics container port |
| controller.createClusterRole | bool | `true` | flag to enable creation of cluster controller role (requires cluster RBAC) |
| controller.deploymentAnnotations | object | `{}` | Annotations to be added to the controller deployment |
| controller.extraArgs | list | `[]` | Additional command line arguments to pass to rollouts-controller.  A list of flags. |
| controller.extraContainers | list | `[]` | Literal yaml for extra containers to be added to controller deployment. |
| controller.extraEnv | list | `[]` | Additional environment variables for rollouts-controller. A list of name/value maps. |
| controller.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| controller.image.registry | string | `"quay.io"` | Registry to use |
| controller.image.repository | string | `"argoproj/argo-rollouts"` | Repository to use |
| controller.image.tag | string | `""` | Overrides the image tag (default is the chart appVersion) |
| controller.initContainers | list | `[]` | Init containers to add to the rollouts controller pod |
| controller.livenessProbe | object | See [values.yaml] | Configure liveness [probe] for the controller |
| controller.logging.format | string | `"text"` | Set the logging format (one of: `text`, `json`) |
| controller.logging.kloglevel | string | `"0"` | Set the klog logging level |
| controller.logging.level | string | `"info"` | Set the logging level (one of: `debug`, `info`, `warn`, `error`) |
| controller.metricProviderPlugins | object | `{}` | Configures 3rd party metric providers for controller |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
| controller.metrics.service.annotations | object | `{}` | Service annotations |
| controller.metrics.service.port | int | `8090` | Metrics service port |
| controller.metrics.service.portName | string | `"metrics"` | Metrics service port name |
| controller.metrics.serviceMonitor.additionalAnnotations | object | `{}` | Annotations to be added to the ServiceMonitor |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` | Labels to be added to the ServiceMonitor |
| controller.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.metrics.serviceMonitor.metricRelabelings | list | `[]` | MetricRelabelConfigs to apply to samples before ingestion |
| controller.metrics.serviceMonitor.namespace | string | `""` | Namespace to be used for the ServiceMonitor |
| controller.metrics.serviceMonitor.relabelings | list | `[]` | RelabelConfigs to apply to samples before scraping |
| controller.nodeSelector | object | `{}` | [Node selector] |
| controller.pdb.annotations | object | `{}` | Annotations to be added to controller [Pod Disruption Budget] |
| controller.pdb.enabled | bool | `false` | Deploy a [Pod Disruption Budget] for the controller |
| controller.pdb.labels | object | `{}` | Labels to be added to controller [Pod Disruption Budget] |
| controller.pdb.maxUnavailable | string | `nil` | Maximum number / percentage of pods that may be made unavailable |
| controller.pdb.minAvailable | string | `nil` | Minimum number / percentage of pods that should remain scheduled |
| controller.podAnnotations | object | `{}` | Annotations to be added to application controller pods |
| controller.priorityClassName | string | `""` | [priorityClassName] for the controller |
| controller.readinessProbe | object | See [values.yaml] | Configure readiness [probe] for the controller |
| controller.replicas | int | `2` | The number of controller pods to run |
| controller.resources | object | `{}` | Resource limits and requests for the controller pods. |
| controller.tolerations | list | `[]` | [Tolerations] for use with node taints |
| controller.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the controller |
| controller.trafficRouterPlugins | object | `{}` | Configures 3rd party traffic router plugins for controller |
| controller.volumeMounts | list | `[]` | Additional volumeMounts to add to the controller container |
| controller.volumes | list | `[]` | Additional volumes to add to the controller pod |
| podAnnotations | object | `{}` | Annotations for the all deployed pods |
| podLabels | object | `{}` | Labels to be added to the Rollout pods |
| podSecurityContext | object | `{"runAsNonRoot":true}` | Security Context to set on pod level |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceAnnotations | object | `{}` | Annotations to be added to the Rollout service |

### Dashboard

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dashboard.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| dashboard.component | string | `"rollouts-dashboard"` | Value of label `app.kubernetes.io/component` |
| dashboard.containerSecurityContext | object | `{}` | Security Context to set on container level |
| dashboard.createClusterRole | bool | `true` | flag to enable creation of dashbord cluster role (requires cluster RBAC) |
| dashboard.deploymentAnnotations | object | `{}` | Annotations to be added to the dashboard deployment |
| dashboard.enabled | bool | `false` | Deploy dashboard server |
| dashboard.extraArgs | list | `[]` | Additional command line arguments to pass to rollouts-dashboard. A list of flags. |
| dashboard.extraEnv | list | `[]` | Additional environment variables for rollouts-dashboard. A list of name/value maps. |
| dashboard.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| dashboard.image.registry | string | `"quay.io"` | Registry to use |
| dashboard.image.repository | string | `"argoproj/kubectl-argo-rollouts"` | Repository to use |
| dashboard.image.tag | string | `""` | Overrides the image tag (default is the chart appVersion) |
| dashboard.ingress.annotations | object | `{}` | Dashboard ingress annotations |
| dashboard.ingress.enabled | bool | `false` | Enable dashboard ingress support |
| dashboard.ingress.extraPaths | list | `[]` | Dashboard ingress extra paths |
| dashboard.ingress.hosts | list | `[]` | Dashboard ingress hosts |
| dashboard.ingress.ingressClassName | string | `""` | Dashboard ingress class name |
| dashboard.ingress.labels | object | `{}` | Dashboard ingress labels |
| dashboard.ingress.pathType | string | `"Prefix"` | Dashboard ingress path type |
| dashboard.ingress.paths | list | `["/"]` | Dashboard ingress paths |
| dashboard.ingress.tls | list | `[]` | Dashboard ingress tls |
| dashboard.logging.kloglevel | string | `"0"` | Set the klog logging level |
| dashboard.logging.level | string | `"info"` | Set the logging level (one of: `debug`, `info`, `warn`, `error`) |
| dashboard.nodeSelector | object | `{}` | [Node selector] |
| dashboard.pdb.annotations | object | `{}` | Annotations to be added to dashboard [Pod Disruption Budget] |
| dashboard.pdb.enabled | bool | `false` | Deploy a [Pod Disruption Budget] for the dashboard |
| dashboard.pdb.labels | object | `{}` | Labels to be added to dashboard [Pod Disruption Budget] |
| dashboard.pdb.maxUnavailable | string | `nil` | Maximum number / percentage of pods that may be made unavailable |
| dashboard.pdb.minAvailable | string | `nil` | Minimum number / percentage of pods that should remain scheduled |
| dashboard.podAnnotations | object | `{}` | Annotations to be added to application dashboard pods |
| dashboard.podSecurityContext | object | `{"runAsNonRoot":true}` | Security Context to set on pod level |
| dashboard.priorityClassName | string | `""` | [priorityClassName] for the dashboard server |
| dashboard.readonly | bool | `false` | Set cluster role to readonly |
| dashboard.replicas | int | `1` | The number of dashboard pods to run |
| dashboard.resources | object | `{}` | Resource limits and requests for the dashboard pods. |
| dashboard.service.annotations | object | `{}` | Service annotations |
| dashboard.service.externalIPs | list | `[]` | Dashboard service external IPs |
| dashboard.service.labels | object | `{}` | Service labels |
| dashboard.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| dashboard.service.loadBalancerSourceRanges | list | `[]` | Source IP ranges to allow access to service from |
| dashboard.service.nodePort | int | `nil` | Service nodePort |
| dashboard.service.port | int | `3100` | Service port |
| dashboard.service.portName | string | `"dashboard"` | Service port name |
| dashboard.service.targetPort | int | `3100` | Service target port |
| dashboard.service.type | string | `"ClusterIP"` | Sets the type of the Service |
| dashboard.serviceAccount.annotations | object | `{}` | Annotations to add to the dashboard service account |
| dashboard.serviceAccount.create | bool | `true` | Specifies whether a dashboard service account should be created |
| dashboard.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| dashboard.tolerations | list | `[]` | [Tolerations] for use with node taints |
| dashboard.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the dashboard server |
| dashboard.volumeMounts | list | `[]` | Additional volumeMounts to add to the dashboard container |
| dashboard.volumes | list | `[]` | Additional volumes to add to the dashboard pod |

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

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[TopologySpreadConstraints]: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
[priorityClassName]: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/
[Pod Disruption Budget]: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets
[values.yaml]: values.yaml
[changelog]: https://artifacthub.io/packages/helm/argo/argo-rollouts?modal=changelog
