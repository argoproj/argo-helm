# Argo Helm Charts

[![Slack](https://img.shields.io/badge/slack-%23argo--helm--charts-brightgreen.svg?logo=slack)](https://argoproj.github.io/community/join-slack)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Chart Publish](https://github.com/argoproj/argo-helm/actions/workflows/publish.yml/badge.svg?branch=main)](https://github.com/argoproj/argo-helm/actions/workflows/publish.yml)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/argo)](https://artifacthub.io/packages/search?repo=argo)
[![CLOMonitor](https://img.shields.io/endpoint?url=https://clomonitor.io/api/projects/cncf/argo/badge)](https://clomonitor.io/projects/cncf/argo)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/argoproj/argo-helm/badge)](https://api.securityscorecards.dev/projects/github.com/argoproj/argo-helm)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/7942/badge)](https://www.bestpractices.dev/projects/7942)

Argo Helm is a collection of **community maintained** charts for [https://argoproj.github.io](https://argoproj.github.io) projects. The charts can be added using following command:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
```

## Version Support Policy
As our project is maintained by a small team, we must focus our limited resources on following upstream projects and ensuring the stability of the latest version.

Consequently, **we do not provide bug fixes or security patches for older versions.** Our official support is limited to **the latest version of the upstream projects** only.

We strongly encourage all users to upgrade to the latest version to benefit from the most recent features, bug fixes, and security patches.

### For Users Unable to Upgrade
> **Warning:**
> This doesn't work all the time. We strongly recommend upgrading Helm Chart to the latest version.

If you are unable to upgrade to the latest version due to specific constraints, please follow the below to patch.

1. Upgrade Helm Chart to the latest version for your minor version. e.g: If you used `v8.2.0`, update to `v8.2.6`, the latest version of `v8.2.x`.
2. Override the image tag (`.global.image.tag`) to use a specific version.

### How You Can Help
This policy may evolve as our team grows. If you are interested in joining our team and helping us expand our support capabilities, we encourage you to read the [Community Membership Guide](https://github.com/argoproj/argoproj/blob/main/community/membership.md) for details.

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

### Custom resource definitions

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of the main four charts (argo-cd, argo-workflows, argo-events, argo-rollouts) by using `--set crds.install=false` when installing the chart.

Helm cannot upgrade custom resource definitions in the `<chart>/crds` folder [by design](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations). Our CRDs have been moved to `<chart>/templates` to address this design decision.

If you are using versions of a chart that have the CRDs in the root of the chart or have elected to manage the Argo CRDs outside of the chart, please use `kubectl` to upgrade CRDs manually from `templates/crds` folder or via the manifests from the upstream project repo:

Example for Argo CD:

```bash
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>"

# Eg. version v2.4.9
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.4.9"
```

### Security Policy

Please refer to [SECURITY.md](SECURITY.md) for details on how to report security issues.

### Changelog

Releases are managed independently for each helm chart, and changelogs are tracked on each release. Read more about this process [here](https://github.com/argoproj/argo-helm/blob/main/CONTRIBUTING.md#changelog).

## Charts use Helm "Capabilities"

Our charts make use of the Helm built-in object "Capabilities":
> This provides information about what capabilities the Kubernetes cluster supports.  
> *Source: https://helm.sh/docs/chart_template_guide/builtin_objects/*

Today we use:

- `.Capabilities.APIVersions.Has` mostly to determine whether the CRDs for ServiceMonitors (from prometheus-operator) exists inside the cluster
- `.Capabilities.KubeVersion.Version` to handle correct apiVersion of a specific resource kind (eg. "policy/v1" vs. "policy/v1beta1")

If you use the charts only to template the manifests, without installing (`helm install ..`), you need to make sure that Helm (or the Helm SDK) receives the available APIs from your Kubernetes cluster.

For this you need to pass the `--api-versions` parameter to the `helm template` command:

```bash
helm template argocd \
  oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --api-versions monitoring.coreos.com/v1 \
  --values my-argocd-values.yaml
```

If you use other tools like [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/builtins/) or [helmfile](https://helmfile.readthedocs.io/en/latest/#configuration) to render it, there are equivalent options.

Example with Kustomize:

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
- name: argo-cd
  repo: oci://ghcr.io/argoproj/argo-helm
  version: x.y.z
  releaseName: argocd
  apiVersions:
  - monitoring.coreos.com/v1
  valuesFile: my-argocd-values.yaml
```

Example with helmfile:

```yaml
# helmfile.yaml
repositories:
  - name: argo
    url: https://argoproj.github.io/argo-helm

apiVersions:
  - monitoring.coreos.com/v1

releases:
  - name: argocd
    namespace: argocd
    chart: argo/argo-cd
    values:
      - my-argocd-values.yaml
```
