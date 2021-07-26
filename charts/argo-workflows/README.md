# Argo Workflows Chart

This is a **community maintained** chart. It is used to set up argo and it's needed dependencies through one command. This is used in conjunction with [helm](https://github.com/kubernetes/helm).

If you want your deployment of this helm chart to most closely match the [argo CLI](https://github.com/argoproj/argo-workflows), you should deploy it in the `kube-system` namespace.

## Pre-Requisites

This chart uses an install hook to configure the CRD definition. Installation of CRDs is a somewhat privileged process in itself and in RBAC enabled clusters the `default` service account for namespaces does not typically have the ability to do create these.

A few options are:

- Manually create a ServiceAccount in the Namespace which your release will be deployed w/ appropriate bindings to perform this action and set the `serviceAccountName` field in the Workflow spec
- Augment the `default` ServiceAccount permissions in the Namespace in which your Release is deployed to have the appropriate permissions

## Usage Notes

This chart defaults to setting the `controller.instanceID.enabled` to `false` now, which means the deployed controller will act upon any workflow deployed to the cluster. If you would like to limit the behavior and deploy multiple workflow controllers, please use the `controller.instanceID.enabled` attribute along with one of it's configuration options to set the `instanceID` of the workflow controller to be properly scoped for your needs.

## Values

The `values.yaml` contains items used to tweak a deployment of this chart.
Fields to note:

- `controller.instanceID.enabled`: If set to true, the Argo Controller will **ONLY** monitor Workflow submissions with a `--instanceid` attribute
- `controller.instanceID.useReleaseName`: If set to true then chart set controller instance id to release name
- `controller.instanceID.explicitID`: Allows customization of an instance id for the workflow controller to monitor
- `controller.workflowNamespaces`: This is a list of namespaces where workflows will be ran

## Breaking changes from the deprecated `argo` chart

1. the `installCRD` value has been removed. CRDs are now only installed from the conventional crds/ directory
1. the CRDs were updated to `apiextensions.k8s.io/v1`
1. the container image registry/project/tag format was changed to be more in line with the more common

   ```yaml
   image:
     registry: quay.io
     repository: argoproj/argocli
     tag: v3.0.1
   ```

   this also makes it easier for automatic update tooling (eg. renovate bot) to detect and update images.

1. switched to quay.io as the default registry for all images
1. removed any included usage of Minio
1. aligned the configuration of serviceAccounts with the argo-cd chart, ie: what used to be `server.createServiceAccount` is now `server.serviceAccount.create`
1. moved the previously known as `telemetryServicePort` inside the `telemetryConfig` as `telemetryConfig.servicePort` - same for `metricsConfig`
