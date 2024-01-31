# Argo-Events Chart

This is a **community maintained** chart. It installs the [argo-events](https://github.com/argoproj/argo-events) application. This application comes packaged with:

- Sensor Custom Resource Definition (See CRD Notes)
- EventSource Custom Resource Definition (See CRD Notes)
- EventBus Custom Resource Definition (See CRD Notes)
- Controller Deployment
- Validation Webhook Deployment
- Service Accounts
- Roles / Cluster Roles
- Role Bindings / Cluster Role Bindings

To regenerate this document, please run:

```shell
./scripts/helm-docs.sh
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm install my-release argo/argo-events
NAME: my-release
...
```

## Upgrading

### Custom resource definitions

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--set crds.install=false` when installing the chart.

You can install the CRDs manually from `templates/crds` folder.

### 2.0.*

Custom resource definitions were moved to `templates` folder so they can be managed by Helm.

To adopt already created CRDs please use following command:

```bash
for crd in "eventbus.argoproj.io" "eventsources.argoproj.io" "sensors.argoproj.io"; do
  kubectl label --overwrite crd $crd app.kubernetes.io/managed-by=Helm
  kubectl annotate --overwrite crd $crd meta.helm.sh/release-namespace=<YOUR_NAMESPACE>
  kubectl annotate --overwrite crd $crd meta.helm.sh/release-name=<YOUR_HELM_RELEASE>
done
```

## Values

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configs.jetstream.settings.maxFileStore | int | `-1` | Maximum size of the file storage (e.g. 20G) |
| configs.jetstream.settings.maxMemoryStore | int | `-1` | Maximum size of the memory storage (e.g. 1G) |
| configs.jetstream.streamConfig.duplicates | string | `"300s"` | Not documented at the moment |
| configs.jetstream.streamConfig.maxAge | string | `"72h"` | Maximum age of existing messages, i.e. “72h”, “4h35m” |
| configs.jetstream.streamConfig.maxBytes | string | `"1GB"` |  |
| configs.jetstream.streamConfig.maxMsgs | int | `1000000` | Maximum number of messages before expiring oldest message |
| configs.jetstream.streamConfig.replicas | int | `3` | Number of replicas, defaults to 3 and requires minimal 3 |
| configs.jetstream.versions[0].configReloaderImage | string | `"natsio/nats-server-config-reloader:latest"` |  |
| configs.jetstream.versions[0].metricsExporterImage | string | `"natsio/prometheus-nats-exporter:latest"` |  |
| configs.jetstream.versions[0].natsImage | string | `"nats:latest"` |  |
| configs.jetstream.versions[0].startCommand | string | `"/nats-server"` |  |
| configs.jetstream.versions[0].version | string | `"latest"` |  |
| configs.nats.versions | list | See [values.yaml] | Supported versions of NATS event bus |
| crds.annotations | object | `{}` | Annotations to be added to all CRDs |
| crds.install | bool | `true` | Install and upgrade CRDs |
| crds.keep | bool | `true` | Keep CRDs on chart uninstall |
| createAggregateRoles | bool | `false` | Create clusterroles that extend existing clusterroles to interact with argo-events crds Only applies for cluster-wide installation (`controller.rbac.namespaced: false`) |
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| fullnameOverride | string | `""` | String to fully override "argo-events.fullname" template |
| global.additionalLabels | object | `{}` | Additional labels to add to all resources |
| global.hostAliases | list | `[]` | Mapping between IP and hostnames that will be injected as entries in the pod's hosts files |
| global.image.imagePullPolicy | string | `"IfNotPresent"` | If defined, a imagePullPolicy applied to all Argo Events deployments |
| global.image.repository | string | `"quay.io/argoproj/argo-events"` | If defined, a repository applied to all Argo Events deployments |
| global.image.tag | string | `""` | Overrides the global Argo Events image tag whose default is the chart appVersion |
| global.imagePullSecrets | list | `[]` | If defined, uses a Secret to pull an image from a private Docker registry or repository |
| global.podAnnotations | object | `{}` | Annotations for the all deployed pods |
| global.podLabels | object | `{}` | Labels for the all deployed pods |
| global.securityContext | object | `{}` | Toggle and define securityContext. See [values.yaml] |
| nameOverride | string | `"argo-events"` | Provide a name in place of `argo-events` |
| openshift | bool | `false` | Deploy on OpenShift |

### Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| controller.containerSecurityContext | object | `{}` | Events controller container-level security context |
| controller.env | list | `[]` | Environment variables to pass to events controller |
| controller.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to events controller |
| controller.extraContainers | list | `[]` | Additional containers to be added to the events controller pods |
| controller.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the events controller |
| controller.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the events controller |
| controller.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the events controller |
| controller.initContainers | list | `[]` | Init containers to add to the events controller pods |
| controller.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
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
| controller.name | string | `"controller-manager"` | Argo Events controller name string |
| controller.nodeSelector | object | `{}` | [Node selector] |
| controller.pdb.annotations | object | `{}` | Annotations to be added to events controller pdb |
| controller.pdb.enabled | bool | `false` | Deploy a PodDisruptionBudget for the events controller |
| controller.pdb.labels | object | `{}` | Labels to be added to events controller pdb |
| controller.podAnnotations | object | `{}` | Annotations to be added to events controller pods |
| controller.podLabels | object | `{}` | Labels to be added to events controller pods |
| controller.priorityClassName | string | `""` | Priority class for the events controller pods |
| controller.rbac.enabled | bool | `true` | Create events controller RBAC |
| controller.rbac.managedNamespace | string | `""` | Additional namespace to be monitored by the controller |
| controller.rbac.namespaced | bool | `false` | Restrict events controller to operate only in a single namespace instead of cluster-wide scope. |
| controller.rbac.rules | list | `[]` | Additional user rules for event controller's rbac |
| controller.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.replicas | int | `1` | The number of events controller pods to run. |
| controller.resources | object | `{}` | Resource limits and requests for the events controller pods |
| controller.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| controller.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| controller.serviceAccount.create | bool | `true` | Create a service account for the events controller |
| controller.serviceAccount.name | string | `""` | Service account name |
| controller.tolerations | list | `[]` | [Tolerations] for use with node taints |
| controller.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the events controller |
| controller.volumeMounts | list | `[]` | Additional volumeMounts to the events controller main container |
| controller.volumes | list | `[]` | Additional volumes to the events controller pod |

### Webhook

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| webhook.affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| webhook.containerSecurityContext | object | `{}` | Event controller container-level security context |
| webhook.enabled | bool | `false` | Enable admission webhook. Applies only for cluster-wide installation |
| webhook.env | list | `[]` (See [values.yaml]) | Environment variables to pass to event controller |
| webhook.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to event controller |
| webhook.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the event controller |
| webhook.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the event controller |
| webhook.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the event controller |
| webhook.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| webhook.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| webhook.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| webhook.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| webhook.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| webhook.name | string | `"events-webhook"` | Argo Events admission webhook name string |
| webhook.nodeSelector | object | `{}` | [Node selector] |
| webhook.pdb.annotations | object | `{}` | Annotations to be added to admission webhook pdb |
| webhook.pdb.enabled | bool | `false` | Deploy a PodDisruptionBudget for the admission webhook |
| webhook.pdb.labels | object | `{}` | Labels to be added to admission webhook pdb |
| webhook.podAnnotations | object | `{}` | Annotations to be added to event controller pods |
| webhook.podLabels | object | `{}` | Labels to be added to event controller pods |
| webhook.port | int | `443` | Port to listen on |
| webhook.priorityClassName | string | `""` | Priority class for the event controller pods |
| webhook.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| webhook.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| webhook.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| webhook.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| webhook.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| webhook.replicas | int | `1` | The number of webhook pods to run. |
| webhook.resources | object | `{}` | Resource limits and requests for the event controller pods |
| webhook.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| webhook.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| webhook.serviceAccount.create | bool | `true` | Create a service account for the admission webhook |
| webhook.serviceAccount.name | string | `""` | Service account name |
| webhook.tolerations | list | `[]` | [Tolerations] for use with node taints |
| webhook.topologySpreadConstraints | list | `[]` | Assign custom [TopologySpreadConstraints] rules to the event controller |
| webhook.volumeMounts | list | `[]` | Additional volumeMounts to the event controller main container |
| webhook.volumes | list | `[]` | Additional volumes to the event controller pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[TopologySpreadConstraints]: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
[values.yaml]: values.yaml
