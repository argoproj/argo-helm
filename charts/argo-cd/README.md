Argo CD Chart
======
A Helm chart for ArgoCD, a declarative, GitOps continuous delivery tool for Kubernetes.

Source code can be found [here](https://argoproj.github.io/argo-cd/)

## Additional Information
This is a **community maintained** chart. This chart installs [argo-cd](https://argoproj.github.io/argo-cd/), a declarative, GitOps continuous delivery tool for Kubernetes.

The default installation is intended to be similar to the provided ArgoCD [releases](https://github.com/argoproj/argo-cd/releases).

This chart currently installs the non-HA version of ArgoCD.

## Upgrading

### 1.8.7 to 2.0.0

`controller.extraArgs`, `repoServer.extraArgs` and `server.extraArgs`  are not arrays of strings intead of a map

What was
```
controller:
  extraArgs:
    insecure: ""
```

is now

```
controller:
  extraArgs:
  - --insecure
```

## Prerequisites

- Kubernetes 1.7+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install --name my-release argo/argo-cd
```

### Helm v3 Compatability

Requires chart version 1.5.1 or newer.

Helm v3 has removed the `install-crds` hook so CRDs are now populated by files in the [crds](./crds) directory. Users of Helm v3 should set the `installCRDs` value to `false` to avoid warnings about nonexistant webhooks.

## Chart Values

| Parameter | Description | Default |
|-----|------|---------|
| global.image.imagePullPolicy | If defined, a imagePullPolicy applied to all ArgoCD deployments. | `"IfNotPresent"` |
| global.image.repository | If defined, a repository applied to all ArgoCD deployments. | `"argoproj/argocd"` |
| global.image.tag | If defined, a tag applied to all ArgoCD deployments. | `"v1.4.2"` |
| global.securityContext | Toggle and define securityContext | See [values.yaml](values.yaml) | 
| global.imagePullSecrets | If defined, uses a Secret to pull an image from a private Docker registry or repository. | `[]` | 
| nameOverride | Provide a name in place of `argocd` | `"argocd"` |
| installCRDs | bool | `true` | Install CRDs if you are using Helm2. |
| configs.knownHosts.data.ssh_known_hosts | Known Hosts | See [values.yaml](values.yaml) |
| configs.secret.argocdServerAdminPassword | Admin password | `null` |
| configs.secret.argocdServerAdminPasswordMtime | Admin password modification time | `date "2006-01-02T15:04:05Z" now` if configs.secret.argocdServerAdminPassword is set |
| configs.secret.bitbucketSecret | BitBucket incoming webhook secret | `""` |
| configs.secret.createSecret | Create the argocd-secret. | `true` |
| configs.secret.githubSecret | GitHub incoming webhook secret | `""` |
| configs.secret.gitlabSecret | GitLab incoming webhook secret | `""` |
| configs.tlsCerts.data."argocd.example.com" | TLS certificate | See [values.yaml](values.yaml) |
| configs.secret.extra | add additional secrets to be added to argocd-secret | `{}` |

## ArgoCD Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | Assign custom affinity rules to the deployment https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| controller.args.operationProcessors | define the controller `--operation-processors` | `"10"` |
| controller.args.statusProcessors | define the controller `--status-processors` | `"20"` |
| controller.clusterAdminAccess.enabled | Enable RBAC for local cluster deployments. | `true` |
| controller.containerPort | Controller listening port. | `8082` |
| controller.extraArgs | Additional arguments for the controller. A list of flags | `[]` |
| controller.env | Environment variables for the controller. | `[]` |
| controller.image.repository | Repository to use for the controller | `global.image.repository` |
| controller.image.imagePullPolicy | Image pull policy for the controller | `global.image.imagePullPolicy` |
| controller.image.tag | Tag to use for the controller | `global.image.tag` |
| controller.livenessProbe.failureThreshold | int | `3` |
| controller.livenessProbe.initialDelaySeconds | int | `10` |
| controller.livenessProbe.periodSeconds | int | `10` |
| controller.livenessProbe.successThreshold | int | `1` |
| controller.livenessProbe.timeoutSeconds | int | `1` |
| controller.logLevel | Controller log level | `"info"` |
| controller.metrics.enabled | Deploy metrics service | `false` |
| controller.metrics.service.annotations | Metrics service annotations | `{}` |
| controller.metrics.service.labels | Metrics service labels | `{}` |
| controller.metrics.service.servicePort | Metrics service port | `8082` |
| controller.metrics.serviceMonitor.enabled | Enable a prometheus ServiceMonitor. | `false` |
| controller.metrics.serviceMonitor.selector | Prometheus ServiceMonitor selector. | `{}` |
| controller.name | Controller name string. | `"application-controller"` |
| controller.nodeSelector | controller node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| controller.podAnnotations | Annotations for the controller pods | `{}` |
| controller.podLabels | Labels for the controller pods | `{}` |
| controller.priorityClassName | Priority class for the controller pods | `""` |
| controller.readinessProbe.failureThreshold | int | `3` |
| controller.readinessProbe.initialDelaySeconds | int | `10` |
| controller.readinessProbe.periodSeconds | int | `10` |
| controller.readinessProbe.successThreshold | int | `1` |
| controller.readinessProbe.timeoutSeconds | int | `1` |
| controller.resources | Resource limits and requests for the controller pods. | `{}` |
| controller.service.annotations | Controller service annotations. | `{}` |
| controller.service.labels | Controller service labels. | `{}` |
| controller.service.port | Controller service port. | `8082` |
| controller.serviceAccount.create | Create a service account for the controller | `true` |
| controller.serviceAccount.name | Service account name. | `"argocd-application-controller"` |
| controller.tolerations | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| controller.volumeMounts | Controller volume mounts | `[]` |
| controller.volumes | Controller volumes | `[]` |

## Argo Repo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| repoServer.affinity | Assign custom affinity rules to the deployment https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| repoServer.autoscaling.enabled | Enable Horizontal Pod Autoscaler (HPA) for the repo server | `false` |
| repoServer.autoscaling.minReplicas | Minimum number of replicas for the repo server HPA | `1` |
| repoServer.autoscaling.maxReplicas | Maximum number of replicas for the repo server HPA | `5` |
| repoServer.autoscaling.targetCPUUtilizationPercentage | Average CPU utilization percentage for the repo server HPA | `50` |
| repoServer.autoscaling.targetMemoryUtilizationPercentage | Average memory utilization percentage for the repo server HPA | `50` |
| repoServer.containerPort | Repo server port | `8081` |
| repoServer.extraArgs | Additional arguments for the repo server. A  list of flags. | `[]` |
| repoServer.env | Environment variables for the repo server. | `[]` |
| repoServer.image.repository | Repository to use for the repo server | `global.image.repository` |
| repoServer.image.imagePullPolicy | Image pull policy for the repo server | `global.image.imagePullPolicy` |
| repoServer.image.tag | Tag to use for the repo server | `global.image.tag` |
| repoServer.livenessProbe.failureThreshold | int | `3` |
| repoServer.livenessProbe.initialDelaySeconds | int | `10` |
| repoServer.livenessProbe.periodSeconds | int | `10` |
| repoServer.livenessProbe.successThreshold | int | `1` |
| repoServer.livenessProbe.timeoutSeconds | int | `1` |
| repoServer.logLevel | Log level | `"info"` |
| repoServer.metrics.enabled | Deploy metrics service | `false` |
| repoServer.metrics.service.annotations | Metrics service annotations | `{}` |
| repoServer.metrics.service.labels | Metrics service labels | `{}` |
| repoServer.metrics.service.servicePort | Metrics service port | `8082` |
| repoServer.metrics.serviceMonitor.enabled | Enable a prometheus ServiceMonitor. | `false` |
| repoServer.metrics.serviceMonitor.selector | Prometheus ServiceMonitor selector. | `{}` |
| repoServer.name | Repo server name | `"repo-server"` |
| repoServer.nodeSelector | controller node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| repoServer.podAnnotations | Annotations for the repo server pods | `{}` |
| repoServer.podLabels | Labels for the repo server pods | `{}` |
| repoServer.priorityClassName | Priority class for the repo server | `""` |
| repoServer.readinessProbe.failureThreshold | int | `3` |
| repoServer.readinessProbe.initialDelaySeconds | int | `10` |
| repoServer.readinessProbe.periodSeconds | int | `10` |
| repoServer.readinessProbe.successThreshold | int | `1` |
| repoServer.readinessProbe.timeoutSeconds | int | `1` |
| repoServer.replicas | The number of repo server pods to run | `1` |
| repoServer.resources | Resource limits and requests for the repo server pods. | `{}` |
| repoServer.service.annotations | Repo server service annotations. | `{}` |
| repoServer.service.labels | Repo server service labels. | `{}` |
| repoServer.service.port | Repo server service port. | `8081` |
| repoServer.tolerations | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| repoServer.volumeMounts | Repo server volume mounts | `[]` |
| repoServer.volumes | Repo server volumes | `[]` |

## Argo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server.affinity | Assign custom affinity rules to the deployment https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| server.autoscaling.enabled | Enable Horizontal Pod Autoscaler (HPA) for the server | `false` |
| server.autoscaling.minReplicas | Minimum number of replicas for the server HPA | `1` |
| server.autoscaling.maxReplicas | Maximum number of replicas for the server HPA | `5` |
| server.autoscaling.targetCPUUtilizationPercentage | Average CPU utilization percentage for the server HPA | `50` |
| server.autoscaling.targetMemoryUtilizationPercentage | Average memory utilization percentage for the server HPA | `50` |
| server.certificate.additionalHosts | Certificate manager additional hosts | `[]` |
| server.certificate.domain | Certificate manager domain | `"argocd.example.com"` |
| server.certificate.enabled | Enables a certificate manager certificate. | `false` |
| server.certificate.issuer | Certificate manager issuer | `{}` |
| server.clusterAdminAccess.enabled | Enable RBAC for local cluster deployments. | `true` |
| server.config | [General Argo CD configuration](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#repositories) | See [values.yaml](values.yaml) |
| server.containerPort | Server container port. | `8080` |
| server.extraArgs | Additional arguments for the server. A list of flags. | `[]` |
| server.env | Environment variables for the server. | `[]` |
| server.image.repository | Repository to use for the server | `global.image.repository` |
| server.image.imagePullPolicy | Image pull policy for the server | `global.image.imagePullPolicy` |
| server.image.tag | Tag to use for the repo server | `global.image.tag` |
| server.ingress.annotations | Additional ingress annotations | `{}` |
| server.ingress.enabled | Enable an ingress resource for the server | `false` |
| server.ingress.hosts | List of ingress hosts | `[]` |
| server.ingress.labels | Additional ingress labels. | `{}` |
| server.ingress.tls | Ingress TLS configuration. | `[]` |
| server.route.enabled | Enable a OpenShift route for the server | `false` |
| server.route.hostname | Hostname of OpenShift route | `""` |
| server.livenessProbe.failureThreshold | int | `3` |
| server.livenessProbe.initialDelaySeconds | int | `10` |
| server.livenessProbe.periodSeconds | int | `10` |
| server.livenessProbe.successThreshold | int | `1` |
| server.livenessProbe.timeoutSeconds | int | `1` |
| server.logLevel | Log level | `"info"` |
| server.metrics.enabled | Deploy metrics service | `false` |
| server.metrics.service.annotations | Metrics service annotations | `{}` |
| server.metrics.service.labels | Metrics service labels | `{}` |
| server.metrics.service.servicePort | Metrics service port | `8082` |
| server.metrics.serviceMonitor.enabled | Enable a prometheus ServiceMonitor. | `false` |
| server.metrics.serviceMonitor.selector | Prometheus ServiceMonitor selector. | `{}` |
| server.name | Argo CD server name | `"server"` |
| server.nodeSelector | controller node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| server.podAnnotations | Annotations for the repo server pods | `{}` |
| server.podLabels | Labels for the repo server pods | `{}` |
| server.priorityClassName | Priority class for the repo server | `""` |
| server.rbacConfig | [Argo CD RBAC policy](https://argoproj.github.io/argo-cd/operator-manual/rbac/) | `{}` |
| server.readinessProbe.failureThreshold | int | `3` |
| server.readinessProbe.initialDelaySeconds | int | `10` |
| server.readinessProbe.periodSeconds | int | `10` |
| server.readinessProbe.successThreshold | int | `1` |
| server.readinessProbe.timeoutSeconds | int | `1` |
| server.replicas | The number of server pods to run | `1` |
| server.resources | Resource limits and requests for the server | `{}` |
| server.service.annotations | Server service annotations | `{}` |
| server.service.labels | Server service labels | `{}` |
| server.service.servicePortHttp | Server service http port | `80` |
| server.service.servicePortHttps | Server service https port | `443` |
| server.service.type | Server service type | `"ClusterIP"` |
| server.serviceAccount.create | Create server service account | `true` |
| server.serviceAccount.name | Server service account name | `"argocd-server"` |
| server.tolerations | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| server.volumeMounts | Server volume mounts | `[]` |
| server.volumes | Server volumes | `[]` |

## Dex

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dex.affinity | Assign custom affinity rules to the deployment https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| dex.containerPortGrpc | GRPC container port | `5557` |
| dex.containerPortHttp | HTTP container port | `5556` |
| dex.enabled | Enable dex | `true` |
| dex.image.imagePullPolicy | Dex imagePullPolicy | `"IfNotPresent"` |
| dex.image.repository | Dex image repository | `"quay.io/dexidp/dex"` |
| dex.image.tag | Dex image tag | `"v2.14.0"` |
| dex.initImage.repository | Argo CD init image repository. | `global.image.repository` |
| dex.initImage.imagePullPolicy | Argo CD init image imagePullPolicy | `global.image.imagePullPolicy` |
| dex.initImage.tag | Argo CD init image tag | `global.image.tag` |
| dex.name | Dex name | `"dex-server"` |
| dex.env | Environment variables for the Dex server. | `[]` |
| dex.nodeSelector | Dex node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| dex.podAnnotations | Annotations for the Dex server pods | `{}` |
| dex.podLabels | Labels for the Dex server pods | `{}` |
| dex.priorityClassName | Priority class for dex | `""` |
| dex.resources | Resource limits and requests for dex | `{}` |
| dex.serviceAccount.create | Create dex service account | `true` |
| dex.serviceAccount.name | Dex service account name | `"argocd-dex-server"` |
| dex.servicePortGrpc | Server GRPC port | `5557` |
| dex.servicePortHttp | Server HTTP port | `5556` |
| dex.tolerations | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| dex.volumeMounts | Dex volume mounts | `"/shared"` |
| dex.volumes | Dex volumes | `{}` |

## Redis

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.affinity | Assign custom affinity rules to the deployment https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| redis.containerPort | Redis container port | `6379` |
| redis.enabled | Enable redis | `true` |
| redis.image.imagePullPolicy | Redis imagePullPolicy | `"IfNotPresent"` |
| redis.image.repository | Redis repository | `"redis"` |
| redis.image.tag | Redis tag | `"5.0.3"` |
| redis.name | Redis name | `"redis"` |
| redis.env | Environment variables for the Redis server. | `[]` |
| redis.nodeSelector | Redis node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| redis.podAnnotations | Annotations for the Redis server pods | `{}` |
| redis.podLabels | Labels for the Redis server pods | `{}` |
| redis.priorityClassName | Priority class for redis | `""` |
| redis.resources | Resource limits and requests for redis | `{}` |
| redis.servicePort | Redis service port | `6379` |
| redis.tolerations | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
