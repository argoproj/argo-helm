# Argo Helm Charts

[![Slack](https://img.shields.io/badge/slack-%23argo--helm--charts-brightgreen.svg?logo=slack)](https://argoproj.github.io/community/join-slack)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Chart Publish](https://github.com/argoproj/argo-helm/actions/workflows/publish.yml/badge.svg?branch=main)](https://github.com/argoproj/argo-helm/actions/workflows/publish.yml)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/argo)](https://artifacthub.io/packages/search?repo=argo)
[![CLOMonitor](https://img.shields.io/endpoint?url=https://clomonitor.io/api/projects/cncf/argo/badge)](https://clomonitor.io/projects/cncf/argo)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/argoproj/argo-helm/badge)](https://api.securityscorecards.dev/projects/github.com/argoproj/argo-helm)

Argo Helm is a collection of **community maintained** charts for [https://argoproj.github.io](https://argoproj.github.io) projects. The charts can be added using following command:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

### Custom resource definitions

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of the main four charts (argo-cd, argo-workflows, argo-events, argo-rollouts) by using `--set crds.install=false` when installing the chart.

Helm cannot upgrade custom resource definitions in the `<chart>/crds` folder [by design](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations). Our CRDs have been moved to `<chart>/templates` to address this design decision.

If you are using versions of a chart that have the CRDs in the root of the chart or have elected to manage the Argo Workflows CRDs outside of the chart, please use `kubectl` to upgrade CRDs manually from [templates/crds](templates/crds/) folder or via the manifests from the upstream project repo:

Example:

```bash
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>"

# Eg. version v2.4.9
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.4.9"
```

### Security Policy

Please refer to [SECURITY.md](SECURITY.md) for details on how to report security issues.

### Changelog

Releases are managed independently for each helm chart, and changelogs are tracked on each release. Read more about this process [here](https://github.com/argoproj/argo-helm/blob/main/CONTRIBUTING.md#changelog).
