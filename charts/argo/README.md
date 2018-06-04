## Argo Chart
This chart is used to set up argo and it's needed dependencies through one command. This is used in conjunction with [helm](https://github.com/kubernetes/helm).

If you want your deployment of this helm chart to most closely match the [argo CLI](https://github.com/argoproj/argo), you should deploy it in the `kube-system` namespace.

## Values

The `values.yaml` contains items used to tweak a deployment of this chart. 
Fields to note:
* `controller.useReleaseAsInstanceID`: If set to true then chart set controller instance id to release name
  - __Note:__ If this is set to false then `controller.instanceId` must be set
* `controller.workflowNamespaces`: This is a list of namespaces where workflows will be ran
* `ui.enableWebConsole`: Enables ability to SSH into pod using web UI
* `minio.install`: If this is true, we'll install [minio](https://github.com/kubernetes/charts/tree/master/stable/minio) and build out the artifactRepository section in workflow controller config map. 
* `artifactRepository.s3.accessKeySecret` and `artifactRepository.s3.secretKeySecret` These by default have the minio default credentials in them. 


