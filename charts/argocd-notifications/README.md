## ArgoCD Notifications Chart

This is a **community maintained** chart. It installs the [argocd-notifications](https://github.com/argoproj-labs/argocd-notifications) application. This application comes packaged with:
- Notifications Controller Deployment
- Notifications Controller ConfigMap
- Notifications Controller Secret
- Service Account
- Roles
- Role Bindings

To regenerate this document, from the root of this chart directory run:

```console
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
```

## Values

### General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Assign custom [affinity] rules |
| argocdUrl | string | `nil` | ArgoCD dashboard url; used in place of {{.context.argocdUrl}} in templates |
| cm.create | bool | `true` | Whether helm chart creates controller config map |
| cm.name | string | `""` | The name of the config map to use. |
| containerSecurityContext | object | `{}` | Container Security Context |
| context | object | `{}` | Define user-defined context |
| extraArgs | list | `[]` | Extra arguments to provide to the controller |
| extraEnv | list | `[]` | Additional container environment variables |
| fullnameOverride | string | `""` | String to partially override "argocd-notifications.fullname" template |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the controller |
| image.repository | string | `"argoprojlabs/argocd-notifications"` | Repository to use for the controller |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| logLevel | string | `"info"` | Set the logging level. (One of: `debug`, `info`, `warn`, `error`) |
| metrics.enabled | bool | `false` | Enables prometheus metrics server |
| metrics.port | int | `9001` | Metrics port |
| metrics.service.annotations | object | `{}` | Metrics service annotations |
| metrics.service.labels | object | `{}` | Metrics service labels |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| nameOverride | string | `"argocd-notifications"` | String to partially override "argocd-notifications.fullname" template |
| nodeSelector | object | `{}` | [Node selector] |
| notifiers | object | See [values.yaml] | Configures notification services |
| podAnnotations | object | `{}` | Annotations to be applied to the controller Pods |
| podLabels | object | `{}` | Labels to be applied to the controller Pods |
| resources | object | `{}` | Resource limits and requests for the controller |
| secret.annotations | object | `{}` | key:value pairs of annotations to be added to the secret |
| secret.create | bool | `true` | Whether helm chart creates controller secret |
| secret.items | object | `{}` | Generic key:value pairs to be inserted into the secret |
| secret.name | string | `""` | The name of the secret to use. |
| securityContext | object | `{"runAsNonRoot":true}` | Pod Security Context |
| serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `"argocd-notifications-controller"` | The name of the service account to use. |
| subscriptions | object | `{}` | Contains centrally managed global application subscriptions |
| templates | object | `{}` | The notification template is used to generate the notification content |
| tolerations | list | `[]` | [Tolerations] for use with node taints |
| triggers | object | `{}` | The trigger defines the condition when the notification should be sent |
| updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |

### Bots

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bots.slack.affinity | object | `{}` | Assign custom [affinity] rules |
| bots.slack.containerSecurityContext | object | `{}` | Container Security Context |
| bots.slack.enabled | bool | `false` | Enable slack bot |
| bots.slack.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the Slack bot |
| bots.slack.image.repository | string | `"argoprojlabs/argocd-notifications"` | Repository to use for the Slack bot |
| bots.slack.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| bots.slack.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| bots.slack.nodeSelector | object | `{}` | [Node selector] |
| bots.slack.resources | object | `{}` | Resource limits and requests for the Slack bot |
| bots.slack.securityContext | object | `{"runAsNonRoot":true}` | Pod Security Context |
| bots.slack.service.annotations | object | `{}` | Service annotations for Slack bot |
| bots.slack.service.port | int | `80` | Service port for Slack bot |
| bots.slack.service.type | string | `"LoadBalancer"` | Service type for Slack bot |
| bots.slack.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| bots.slack.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| bots.slack.serviceAccount.name | string | `"argocd-notifications-bot"` | The name of the service account to use. |
| bots.slack.tolerations | list | `[]` | [Tolerations] for use with node taints |
| bots.slack.updateStrategy | object | `{"type":"Recreate"}` | The deployment strategy to use to replace existing pods with new ones |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[values.yaml]: values.yaml
