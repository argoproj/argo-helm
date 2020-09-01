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

## Notes on CRD Installation

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--set installCRD=false` when installing the chart.

You can install the CRDs manually from `crds` folder.