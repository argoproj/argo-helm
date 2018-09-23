# Argo-Events Helm Chart

This helm chart installs the [argo-events](https://github.com/argoproj/argo-events) application. This application comes packaged with:
- Sensor Custom Resource Definition
- Sensor Controller Deployment
- Sensor Controller ConfigMap
- Sensor Controller Service Account
- Sensor Controller Cluster Roles
- Sensor Controller Cluster Role Binding

- Gateway Custom Resource Definition
- Gateway Controller Deployment
- Gateway Controller ConfigMap
- Gateway Controller Service Account
- Gateway Controller Cluster Roles
- Gateway Controller Cluster Role Binding

Note: the associated `argo-events` cluster role and cluster role bindings can be found in the [roles](https://blade-git.blackrock.com/cloud-native/roles) repository. The purpose that these aren't included in this Helm chart is that we do not have the required permissions to create these resources in the Kubernetes clusters. Reach out to `+Group Kubernetes Support` for help in setting up these roles.

## Chart Values
