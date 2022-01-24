# Argo-Events Chart

This is a **community maintained** chart. It installs the [argo-events](https://github.com/argoproj/argo-events) application. This application comes packaged with:
- Sensor Custom Resource Definition (See CRD Notes)
- EventSource Custom Resource Definition (See CRD Notes)
- EventBus Custom Resource Definition (See CRD Notes)
- Sensor Controller Deployment
- EventSource Controller Deployment
- EventBus Controller Deployment
- Service Account
- Roles
- Role Bindings
- Cluster Roles
- Cluster Role Bindings

To regenerate this document, from the root of this chart directory run:

```shell
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

## Notes on CRD Installation

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--skip-crds` when installing the chart.

You can install the CRDs manually from `crds` folder.

## Values

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalSaNamespaces | list | `[]` | Create service accounts in additional namespaces specified The SA will always be created in the release namespaces |
| additionalServiceAccountRules | list | (See [values.yaml]) | Additional rules |
| imagePullPolicy | string | `"Always"` | The image pull policy |
| imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| registry | string | `"quay.io"` | docker registry |
| securityContext | object | `{"runAsNonRoot":true,"runAsUser":9731}` | Common PodSecurityContext for all controllers |
| serviceAccount | string | `"argo-events-sa"` | ServiceAccount to use for running controller. |
| serviceAccountAnnotations | object | `{}` | Annotations applied to created service account. Can be used to enable GKE workload identity, or other use-cases |
| singleNamespace | bool | `true` | Whether to run in namespaced scope. Set `singleNamespace` to false to have the controllers listen on all namespaces.  Otherwise the controllers will listen on the namespace where the chart is installed in. |

### Event Bus Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eventbusController.affinity | object | `{}` | Assign custom [affinity] rules to the event bus controller |
| eventbusController.containerSecurityContext | object | `{}` | Event bus controller container-level security context |
| eventbusController.extraEnv | list | `[]` | Additional environment variables to pass to event bus controller |
| eventbusController.image | string | `"argoproj/argo-events"` | Repository to use for the event bus controller |
| eventbusController.name | string | `"eventbus-controller"` | Event bus controller name |
| eventbusController.natsMetricsExporterImage | string | `"natsio/prometheus-nats-exporter:0.8.0"` | NATS metrics exporter container image to use for the event bus |
| eventbusController.natsStreamingImage | string | `"nats-streaming:0.22.1"` | NATS streaming container image to use for the event bus |
| eventbusController.nodeSelector | object | `{}` | [Node selector] |
| eventbusController.podAnnotations | object | `{}` | Annotations to be added to event bus controller pods |
| eventbusController.podLabels | object | `{}` | Labels to be added to event event bus controller pods |
| eventbusController.priorityClassName | string | `""` | Priority class for the event bus controller |
| eventbusController.replicaCount | int | `1` | The number of event bus controller pods to run |
| eventbusController.resources | object | `{}` | Resource limits and requests for the event bus controller pods |
| eventbusController.tag | string | `""` (default is the chart appVersion) | Overrides the image tag |
| eventbusController.tolerations | list | `[]` | [Tolerations] for use with node taints |

### Event Source Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eventsourceController.affinity | object | `{}` | Assign custom [affinity] rules to the event source controller |
| eventsourceController.containerSecurityContext | object | `{}` | Event source controller container-level security context |
| eventsourceController.eventsourceImage | string | `"argoproj/argo-events"` | Repository to use for the event source image |
| eventsourceController.extraEnv | list | `[]` | Additional environment variables to pass to event source controller |
| eventsourceController.image | string | `"argoproj/argo-events"` | Repository to use for the event source controller |
| eventsourceController.name | string | `"eventsource-controller"` | Event source controller name |
| eventsourceController.nodeSelector | object | `{}` | [Node selector] |
| eventsourceController.podAnnotations | object | `{}` | Annotations to be added to event source controller pods |
| eventsourceController.podLabels | object | `{}` | Labels to be added to event source controller pods |
| eventsourceController.priorityClassName | string | `""` | Priority class for the event source controller |
| eventsourceController.replicaCount | int | `1` | The number of event source controller pods to run |
| eventsourceController.resources | object | `{}` | Resource limits and requests for the event source controller pods |
| eventsourceController.tag | string | `""` (default is the chart appVersion) | Overrides the image tag |
| eventsourceController.tolerations | list | `[]` | [Tolerations] for use with node taints |

### Sensor Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| sensorController.affinity | object | `{}` | Assign custom [affinity] rules to the sensor controller |
| sensorController.containerSecurityContext | object | `{}` | Sensor controllers container-level security context |
| sensorController.extraEnv | list | `[]` | Additional environment variables to pass to sensor controller |
| sensorController.image | string | `"argoproj/argo-events"` | Repository to use for the sensor controller |
| sensorController.name | string | `"sensor-controller"` | Sensor controller name |
| sensorController.nodeSelector | object | `{}` | [Node selector] |
| sensorController.podAnnotations | object | `{}` | Annotations to be added to sensor controller pods |
| sensorController.podLabels | object | `{}` | Labels to be added to sensor controller pods |
| sensorController.priorityClassName | string | `""` | Priority class for the sensor controller |
| sensorController.replicaCount | int | `1` | The number of sensor controller pods to run |
| sensorController.resources | object | `{}` | Resource limits and requests for the sensor controller pods |
| sensorController.sensorImage | string | `"argoproj/argo-events"` | Repository to use for the sensor image |
| sensorController.tag | string | `""` (default is the chart appVersion) | Overrides the image tag |
| sensorController.tolerations | list | `[]` | [Tolerations] for use with node taints |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[values.yaml]: values.yaml
