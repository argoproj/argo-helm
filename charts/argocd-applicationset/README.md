# Argo CD ApplicationSet Chart

A Helm chart for Argo CD ApplicationSet, a controller to programmatically generate Argo CD Application.

Source code can be found [here](https://github.com/argoproj-labs/applicationset/)

## Additional Information

This is a **community maintained** chart. This chart installs the [applicationset](https://github.com/argoproj-labs/applicationset) controller.

This chart currently installs the non-HA version of Argo CD ApplicationSet.

## Prerequisites

- Helm v3.0.0+
- The ApplicationSet controller **must** be installed into the same namespace as the Argo CD it is targetting.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm install --name my-release argo/argocd-applicationset
NAME: my-release
...
```

### Testing

Users can test the chart with [kind](https://kind.sigs.k8s.io/) and [ct](https://github.com/helm/chart-testing).

```console
kind create cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
ct install --namespace argocd
```

## Notes on CRD Installation

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--skip-crds` when installing the chart.

You then can install the CRDs manually from `crds` folder or via the manifests from the upstream project repo:

```console
kubectl apply -k https://github.com/argoproj-labs/applicationset.git/manifests/crds?ref=<appVersion>

# Eg. version v0.1.0
kubectl apply -k https://github.com/argoproj-labs/applicationset.git/manifests/crds?ref=v0.1.0
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | [Assign custom affinity rules to the deployment](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| apiVersionOverrides.ingress | string | `""` | String to override apiVersion of ingresses rendered by this helm chart |
| args.argocdRepoServer | string | `"argocd-repo-server:8081"` | The default Argo CD repo server address |
| args.debug | bool | `false` | Print debug logs |
| args.dryRun | bool | `false` | Enable dry run mode |
| args.enableLeaderElection | bool | `false` | The default leader election setting |
| args.metricsAddr | string | `":8080"` | The default metric address |
| args.namespace | string | `""` | Namespace where ArgoCD is deployed to (defaults to .Release.Namespace) |
| args.policy | string | `"sync"` | How application is synced between the generator and the cluster |
| args.probeBindAddr | string | `":8081"` | The default health check port |
| extraArgs | list | `[]` | List of extra cli args to add |
| extraVolumeMounts | list | `[]` | List of extra mounts to add (normally used with extraVolumes) |
| extraVolumes | list | `[]` | List of extra volumes to add |
| fullnameOverride | string | `""` | Override the default fully qualified app name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"quay.io/argoproj/argocd-applicationset"` | The image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | If defined, uses a Secret to pull an image from a private Docker registry or repository. |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| metrics.enabled | bool | `false` | Deploy metrics service |
| metrics.service.annotations | object | `{}` | Metrics service annotations |
| metrics.service.labels | object | `{}` | Metrics service labels |
| metrics.service.servicePort | int | `8085` | Metrics service port |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| mountGPGKeyringVolume | bool | `true` | Mount an emptyDir volume for `gpg-keyring` |
| mountGPGKeysVolume | bool | `false` | Mount the `argocd-gpg-keys-cm` volume |
| mountSSHKnownHostsVolume | bool | `true` | Mount the `argocd-ssh-known-hosts-cm` volume |
| mountTLSCertsVolume | bool | `true` | Mount the `argocd-tls-certs-cm` volume |
| nameOverride | string | `""` | Provide a name in place of `argocd-applicationset` |
| nodeSelector | object | `{}` | [Node selector](https://kubernetes.io/docs/user-guide/node-selection/) |
| podAnnotations | object | `{}` | Annotations for the controller pods |
| podLabels | object | `{}` | Labels for the controller pods |
| podSecurityContext | object | `{}` | Pod Security Context |
| priorityClassName | string | `""` | If specified, indicates the pod's priority. If not specified, the pod priority will be default or zero if there is no default. |
| rbac.pspEnabled | bool | `true` | Enable Pod Security Policy |
| replicaCount | int | `1` | The number of controller pods to run |
| resources | object | `{}` | Resource limits and requests for the controller pods. |
| securityContext | object | `{}` | Security Context |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | [Tolerations for use with node taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| webhook.ingress.annotations | object | `{}` | Additional ingress annotations |
| webhook.ingress.enabled | bool | `false` | Enable an ingress resource for Webhooks |
| webhook.ingress.extraPaths | list | `[]` | Additional ingress paths |
| webhook.ingress.hosts | list | `[]` | List of ingress hosts |
| webhook.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| webhook.ingress.labels | object | `{}` | Additional ingress labels |
| webhook.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| webhook.ingress.paths | list | `["/api/webhook"]` | List of ingress paths |
| webhook.ingress.tls | list | `[]` | Ingress TLS configuration |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)
