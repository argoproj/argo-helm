Argo Rollouts Chart
=============
A Helm chart for Argo Rollouts, progressive delivery for Kubernetes.

Current chart version is `0.2.0`

Source code can be found [here](https://github.com/argoproj/argo-rollouts)

## Additional Information
This is a **community maintained** chart. This chart installs [argo-rollouts](https://argoproj.github.io/argo-rollouts/), progressive delivery for Kubernetes.

The default installation is intended to be similar to the provided Argo Rollouts [releases](https://github.com/argoproj/argo-rollouts/releases).

## Prerequisites

- Kubernetes 1.7+


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install --name my-release argo/argo-rollouts
```

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterInstall | bool | `true` |  |
| controller.component | string | `"rollouts-controller"` |  |
| controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.image.repository | string | `"argoproj/argo-rollouts"` |  |
| controller.image.tag | string | `"v0.7.0"` |  |
| controller.name | string | `"argo-rollouts"` |  |
| imagePullSecrets | list | `[]` |  |
| installCRDs | bool | `true` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| serviceAccount.name | string | `"argo-rollouts"` |  |
