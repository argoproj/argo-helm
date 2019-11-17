# Argo-Events Chart

This is a **community maintained** chart. It installs the [argo-events](https://github.com/argoproj/argo-events) application. This application comes packaged with:
- Sensor Custom Resource Definition (See CRD Notes)
- Gateway Custom Resource Definition (See CRD Notes)
- Sensor Controller Deployment
- Sensor Controller ConfigMap
- Gateway Controller Deployment
- Gateway Controller ConfigMap
- Service Account
- Cluster Roles
- Cluster Role Bindings

## Notes on CRD Installation

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--set installCRD=false` when installing the chart.

You can install the CRDs manually like so:

```
kubectl apply -f https://github.com/argoproj/argo-events/raw/v0.11/hack/k8s/manifests/sensor-crd.yaml
kubectl apply -f https://github.com/argoproj/argo-events/raw/v0.11/hack/k8s/manifests/gateway-crd.yaml
```
