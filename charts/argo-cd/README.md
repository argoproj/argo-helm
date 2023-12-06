# Argo CD Chart

A Helm chart for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes.

Source code can be found here:

* <https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd>
* <https://github.com/argoproj/argo-cd>

This is a **community maintained** chart. This chart installs [argo-cd](https://argo-cd.readthedocs.io/en/stable/), a declarative, GitOps continuous delivery tool for Kubernetes.

The default installation is intended to be similar to the provided Argo CD [releases](https://github.com/argoproj/argo-cd/releases).

If you want to avoid including sensitive information unencrypted (clear text) in your version control, make use of the [declarative setup] of Argo CD.
For instance, rather than adding repositories and their keys in your Helm values, you could deploy [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) with contents as seen in this [repositories section](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) or any other secrets manager service (i.e. HashiCorp Vault, AWS/GCP Secrets Manager, etc.).

## High Availability

This chart installs the non-HA version of Argo CD by default. If you want to run Argo CD in HA mode, you can use one of the example values in the next sections.
Please also have a look into the upstream [Operator Manual regarding High Availability](https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/) to understand how scaling of Argo CD works in detail.

> **Warning:**
> You need at least 3 worker nodes as the HA mode of redis enforces Pods to run on separate nodes.

### HA mode with autoscaling

```yaml
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2
```

### HA mode without autoscaling

```yaml
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  replicas: 2

repoServer:
  replicas: 2

applicationSet:
  replicas: 2
```

### Synchronizing Changes from Original Repository

In the original [Argo CD repository](https://github.com/argoproj/argo-cd/) an [`manifests/install.yaml`](https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml) is generated using `kustomize`. It's the basis for the installation as [described in the docs](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd).

When installing Argo CD using this helm chart the user should have a similar experience and configuration rolled out. Hence, it makes sense to try to achieve a similar output of rendered `.yaml` resources when calling `helm template` using the default settings in `values.yaml`.

To update the templates and default settings in `values.yaml` it may come in handy to look up the diff of the `manifests/install.yaml` between two versions accordingly. This can either be done directly via github and look for `manifests/install.yaml`:

https://github.com/argoproj/argo-cd/compare/v1.8.7...v2.0.0#files_bucket

Or you clone the repository and do a local `git-diff`:

```bash
git clone https://github.com/argoproj/argo-cd.git
cd argo-cd
git diff v1.8.7 v2.0.0 -- manifests/install.yaml
```

Changes in the `CustomResourceDefinition` resources shall be fixed easily by copying 1:1 from the [`manifests/crds` folder](https://github.com/argoproj/argo-cd/tree/master/manifests/crds) into this [`charts/argo-cd/templates/crds` folder](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd/templates/crds).

### Custom resource definitions

Some users would prefer to install the CRDs _outside_ of the chart. You can disable the CRD installation of this chart by using `--set crds.install=false` when installing the chart.

Helm cannot upgrade custom resource definitions in the `<chart>/crds` folder [by design](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations). Starting with 5.2.0, the CRDs have been moved to `<chart>/templates` to address this design decision.

If you are using Argo CD chart version prior to 5.2.0 or have elected to manage the Argo CD CRDs outside of the chart, please use `kubectl` to upgrade CRDs manually from [templates/crds](templates/crds/) folder or via the manifests from the upstream project repo:

```bash
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>"

# Eg. version v2.4.9
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.4.9"
```

## Changelog

For full list of changes please check ArtifactHub [changelog].

Highlighted versions provide information about additional steps that should be performed by user when upgrading to newer version.

### 5.35.0
This version supports Kubernetes version `>=1.23.0-0`. The current supported version of Kubernetes is v1.24 or later and we align with the Amazon EKS calendar, because many AWS users follow a conservative approach.

Please see more information about EoL: [Amazon EKS EoL][EKS EoL].

### 5.31.0
The manifests are now using [`tini` as entrypoint][tini], instead of `entrypoint.sh`. Until Argo CD v2.8, `entrypoint.sh` is retained for upgrade compatibility.
This means that the deployment manifests have to be updated after upgrading to Argo CD v2.7, and before upgrading to Argo CD v2.8 later.
In case the manifests are updated before moving to Argo CD v2.8, the containers will not be able to start.

### 5.26.0

This version adds support for Config Management Plugins using the sidecar model and configured in a ConfigMap named `argocd-cmp-cm`.
Users will need to migrate from the previous `argocd-cm` ConfigMap method to using the sidecar method before Argo CD v2.8. See the [Argo CD CMP migration guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/#migrating-from-argocd-cm-plugins) for more specifics.

To migrate your plugins, you can now set the `configs.cmp.create` to `true` and move your plugins from `configs.cm` to `configs.cmp.plugins`.
You will also need to configure the sidecar containers under `repoServer.extraContainers` and ensure you are mounting any custom volumes you need from `repoServer.volumes` into here also.

### 5.24.0

This version adds additional global parameters for scheduling (`nodeSelector`, `tolerations`, `topologySpreadConstraints`).
Default `global.affinity` rules can be disabled when `none` value is used for the preset.

### 5.22.0

This version adds `global.affinity` options that are used as a presets. Override on component level works as before and replaces the default preset completely.

### 5.19.0

This version consolidates config for custom repository TLS certificates and SSH known hosts. If you provided these values (`configs.knownHosts.*`, `configs.knownHostsAnnotations`, `configs.tlsCerts`, `configs.tlsCertsAnnotations`) please move them into new `configs.ssh` and `configs.tls` sections.
You can also use new option `configs.ssh.extraHosts` to configure your SSH keys without maintaing / overwritting keys for public Git repositories.

### 5.13.0

This version reduces history limit for Argo CD deployment replicas to 3 to provide more visibility for Argo CD deployments that manage itself. If you need more deployment revisions for rollbacks set `global.revisionHistoryLimit` parameter.

### 5.12.0

If Argo CD is managing termination of TLS and you are using `configs.secret.argocdServerTlsConfig` option to provide custom TLS configuration for this chart, please use `server.certificate` or `server.certificateSecret` instead.
For the secrets for tls termination, please use a secret named `argocd-server-tls` instead of `argocd-secret`.
For the technical details please check the [Argo CD documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-certificates-used-by-argocd-server). When transitioning from the one secret to the other pay attention to `tls.key` and `tls.crt` keys.

### 5.10.0

This version hardens security by configuring default container security contexts and adds hard requirement for Kubernetes 1.22+ to work properly.
The change aligns chart with officially [supported versions](https://argo-cd.readthedocs.io/en/release-2.5/operator-manual/installation/#supported-versions) by upstream project.

### 5.7.0

This version introcudes new `configs.cm` and `configs.rbac` sections that replaces `server.config` and `server.rbacConfig` respectively.
Please move your current configuration to the new place. The Argo CD RBAC config now also sets defaults in the `argocd-rbac-cm`.
If you have manually created this ConfigMap please ensure templating is disabled so you will not lose your changes.

### 5.5.20

This version moved API version templates into dedicated helper. If you are using these in your umbrella
chart please migrate your templates to pattern `argo-cd.apiVersion.<component>`.

### 5.5.0

This version introduces new `configs.params` section that replaces command line arguments for containers.
Please refer to documentation in values.yaml for migrating the configuration.

### 5.2.0

Custom resource definitions were moved to `templates` folder so they can be managed by Helm.

To adopt already created CRDs, please use following command:

```bash
YOUR_ARGOCD_NAMESPACE="" # e.g. argo-cd
YOUR_ARGOCD_RELEASENAME="" # e.g. argo-cd

for crd in "applications.argoproj.io" "applicationsets.argoproj.io" "argocdextensions.argoproj.io" "appprojects.argoproj.io"; do
  kubectl label --overwrite crd $crd app.kubernetes.io/managed-by=Helm
  kubectl annotate --overwrite crd $crd meta.helm.sh/release-namespace="$YOUR_ARGOCD_NAMESPACE"
  kubectl annotate --overwrite crd $crd meta.helm.sh/release-name="$YOUR_ARGOCD_RELEASENAME"
done
```

### 5.0.0

This version **removes support for**:

- deprecated repository credentials (parameter `configs.repositoryCredentials`)
- option to run application controller as a Deployment
- the parameters `server.additionalApplications` and `server.additionalProjects`

Please carefully read the following section if you are using these parameters!

In order to upgrade Applications and Projects safely against CRDs' upgrade, `server.additionalApplications` and `server.additionalProjects` are moved to [argocd-apps](../argocd-apps).

If you are using `server.additionalApplications` or `server.additionalProjects`, you can adopt to [argocd-apps](../argocd-apps) as below:

1. Add [helm.sh/resource-policy annotation](https://helm.sh/docs/howto/charts_tips_and_tricks/#tell-helm-not-to-uninstall-a-resource) to avoid resources being removed by upgrading Helm chart

You can keep your existing CRDs by adding `"helm.sh/resource-policy": keep` on `additionalAnnotations`, under `server.additionalApplications` and `server.additionalProjects` blocks, and running `helm upgrade`.

e.g:

```yaml
server:
  additionalApplications:
    - name: guestbook
      namespace: argocd
      additionalLabels: {}
      additionalAnnotations:
        "helm.sh/resource-policy": keep # <-- add this
      finalizers:
      - resources-finalizer.argocd.argoproj.io
      project: guestbook
      source:
        repoURL: https://github.com/argoproj/argocd-example-apps.git
        targetRevision: HEAD
        path: guestbook
        directory:
          recurse: true
      destination:
        server: https://kubernetes.default.svc
        namespace: guestbook
      syncPolicy:
        automated:
          prune: false
          selfHeal: false
      ignoreDifferences:
      - group: apps
        kind: Deployment
        jsonPointers:
        - /spec/replicas
      info:
      - name: url
        value: https://argoproj.github.io/
```

You can also keep your existing CRDs by running the following scripts.

```bash
# keep Applications
for app in "guestbook"; do
  kubectl annotate --overwrite application $app helm.sh/resource-policy=keep
done

# keep Projects
for project in "guestbook"; do
  kubectl annotate --overwrite appproject $project helm.sh/resource-policy=keep
done
```

2. Upgrade argo-cd Helm chart to v5.0.0

3. Remove keep [helm.sh/resource-policy annotation](https://helm.sh/docs/howto/charts_tips_and_tricks/#tell-helm-not-to-uninstall-a-resource)

```bash
# delete annotations from Applications
for app in "guestbook"; do
  kubectl annotate --overwrite application $app helm.sh/resource-policy-
done

# delete annotations from Projects
for project in "guestbook"; do
  kubectl annotate --overwrite appproject $project helm.sh/resource-policy-
done
```

4. Adopt existing resources to [argocd-apps](../argocd-apps)

### 4.9.0

This version starts to use upstream image with applicationset binary. Start command was changed from `applicationset-controller` to `argocd-applicationset-controller`

### 4.3.*

With this minor version, the notification notifier's `service.slack` is no longer configured by default.

### 4.0.0 and above

This helm chart version deploys Argo CD v2.3. The Argo CD Notifications and ApplicationSet are part of Argo CD now. You no longer need to install them separately. The Notifications and ApplicationSet components **are bundled into default** Argo CD installation.
Please read the [v2.2 to 2.3 upgrade instructions] in the upstream repository.

### 3.13.0

This release removes the flag `--staticassets` from argocd server as it has been dropped upstream. If this flag needs to be enabled e.g for older releases of Argo CD, it can be passed via the `server.extraArgs` field

### 3.10.2

Argo CD has recently deprecated the flag `--staticassets` and from chart version `3.10.2` has been disabled by default
It can be re-enabled by setting `server.staticAssets.enabled` to true

### 3.8.1

This bugfix version potentially introduces a rename (and recreation) of one or more ServiceAccounts. It _only happens_ when you use one of these customization:

```yaml
# Case 1) - only happens when you do not specify a custom name (repoServer.serviceAccount.name)
repoServer:
  serviceAccount:
    create: true

# Case 2)
controller:
  serviceAccount:
    name: "" # or <nil>

# Case 3)
dex:
  serviceAccount:
    name: "" # or <nil>

# Case 4)
server:
  serviceAccount:
    name: "" # or <nil>
```

Please check if you are affected by one of these cases **before you upgrade**, especially when you use **cloud IAM roles for service accounts.** (eg. IRSA on AWS or Workload Identity for GKE)

### 3.2.*

With this minor version we introduced the evaluation for the ingress manifest (depending on the capabilities version), See [Pull Request](https://github.com/argoproj/argo-helm/pull/637).
[Issue 703](https://github.com/argoproj/argo-helm/issues/703) reported that the capabilities evaluation is **not handled correctly when deploying the chart via an Argo CD instance**,
especially deploying on clusters running a cluster version prior to `1.19` (which misses  `Ingress` on apiVersion `networking.k8s.io/v1`).

If you are running a cluster version prior to `1.19` you can avoid this issue by directly installing chart version `3.6.0` and setting `kubeVersionOverride` like:

```yaml
kubeVersionOverride: "1.18.0"
```

Then you should no longer encounter this issue.

### 3.0.0 and above

Helm apiVersion switched to `v2`. Requires Helm `3.0.0` or above to install. [Read More](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/) on how to migrate your release from Helm 2 to Helm 3.

### 2.14.7 and above

The `matchLabels` key in the Argo CD Application Controller is no longer hard-coded. Note that labels are immutable so caution should be exercised when making changes to this resource.

### 2.10.x to 2.11.0

The application controller is now available as a `StatefulSet` when the `controller.enableStatefulSet` flag is set to true. Depending on your Helm deployment this may be a downtime or breaking change if enabled when using HA and will become the default in 3.x.

### 1.8.7 to 2.x.x

`controller.extraArgs`, `repoServer.extraArgs` and `server.extraArgs`  are now arrays of strings instead of a map

What was

```yaml
server:
  extraArgs:
    insecure: ""
```

is now

```yaml
server:
  extraArgs:
  - --insecure
```

## Prerequisites

- Kubernetes: `>=1.23.0-0`
  - We align with [Amazon EKS calendar][EKS EoL] because there are many AWS users and it's a conservative approach.
  - Please check [Support Matrix of Argo CD][Kubernetes Compatibility Matrix] for official info.
- Helm v3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm install my-release argo/argo-cd
NAME: my-release
...
```

## General parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersionOverrides.cloudgoogle | string | `""` | String to override apiVersion of GKE resources rendered by this helm chart |
| crds.additionalLabels | object | `{}` | Addtional labels to be added to all CRDs |
| crds.annotations | object | `{}` | Annotations to be added to all CRDs |
| crds.install | bool | `true` | Install and upgrade CRDs |
| crds.keep | bool | `true` | Keep CRDs on chart uninstall |
| createAggregateRoles | bool | `false` | Create aggregated roles that extend existing cluster roles to interact with argo-cd resources |
| createClusterRoles | bool | `true` | Create cluster roles for cluster-wide installation. |
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| fullnameOverride | string | `""` | String to fully override `"argo-cd.fullname"` |
| kubeVersionOverride | string | `""` | Override the Kubernetes version, which is used to evaluate certain manifests |
| nameOverride | string | `"argocd"` | Provide a name in place of `argocd` |
| openshift.enabled | bool | `false` | enables using arbitrary uid for argo repo server |

## Global Configs

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.addPrometheusAnnotations | bool | `false` | Add Prometheus scrape annotations to all metrics services. This can be used as an alternative to the ServiceMonitors. |
| global.additionalLabels | object | `{}` | Common labels for the all resources |
| global.affinity.nodeAffinity.matchExpressions | list | `[]` | Default match expressions for node affinity |
| global.affinity.nodeAffinity.type | string | `"hard"` | Default node affinity rules. Either: `none`, `soft` or `hard` |
| global.affinity.podAntiAffinity | string | `"soft"` | Default pod anti-affinity rules. Either: `none`, `soft` or `hard` |
| global.certificateAnnotations | object | `{}` | Annotations for the all deployed Certificates |
| global.deploymentAnnotations | object | `{}` | Annotations for the all deployed Deployments |
| global.deploymentStrategy | object | `{}` | Deployment strategy for the all deployed Deployments |
| global.env | list | `[]` | Environment variables to pass to all deployed Deployments |
| global.hostAliases | list | `[]` | Mapping between IP and hostnames that will be injected as entries in the pod's hosts files |
| global.image.imagePullPolicy | string | `"IfNotPresent"` | If defined, a imagePullPolicy applied to all Argo CD deployments |
| global.image.repository | string | `"quay.io/argoproj/argocd"` | If defined, a repository applied to all Argo CD deployments |
| global.image.tag | string | `""` | Overrides the global Argo CD image tag whose default is the chart appVersion |
| global.imagePullSecrets | list | `[]` | Secrets with credentials to pull images from a private registry |
| global.logging.format | string | `"text"` | Set the global logging format. Either: `text` or `json` |
| global.logging.level | string | `"info"` | Set the global logging level. One of: `debug`, `info`, `warn` or `error` |
| global.networkPolicy.create | bool | `false` | Create NetworkPolicy objects for all components |
| global.networkPolicy.defaultDenyIngress | bool | `false` | Default deny all ingress traffic |
| global.nodeSelector | object | `{}` | Default node selector for all components |
| global.podAnnotations | object | `{}` | Annotations for the all deployed pods |
| global.podLabels | object | `{}` | Labels for the all deployed pods |
| global.priorityClassName | string | `""` | Default priority class for all components |
| global.revisionHistoryLimit | int | `3` | Number of old deployment ReplicaSets to retain. The rest will be garbage collected. |
| global.securityContext | object | `{}` (See [values.yaml]) | Toggle and define pod-level security context. |
| global.statefulsetAnnotations | object | `{}` | Annotations for the all deployed Statefulsets |
| global.tolerations | list | `[]` | Default tolerations for all components |
| global.topologySpreadConstraints | list | `[]` | Default [TopologySpreadConstraints] rules for all components |

## Argo CD Configs

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configs.clusterCredentials | list | `[]` (See [values.yaml]) | Provide one or multiple [external cluster credentials] |
| configs.cm."admin.enabled" | bool | `true` | Enable local admin user |
| configs.cm."application.instanceLabelKey" | string | Defaults to app.kubernetes.io/instance | The name of tracking label used by Argo CD for resource pruning |
| configs.cm."exec.enabled" | bool | `false` | Enable exec feature in Argo UI |
| configs.cm."server.rbac.log.enforce.enable" | bool | `false` | Enable logs RBAC enforcement |
| configs.cm."timeout.hard.reconciliation" | string | `"0s"` | Timeout to refresh application data as well as target manifests cache |
| configs.cm."timeout.reconciliation" | string | `"180s"` | Timeout to discover if a new manifests version got published to the repository |
| configs.cm.annotations | object | `{}` | Annotations to be added to argocd-cm configmap |
| configs.cm.create | bool | `true` | Create the argocd-cm configmap for [declarative setup] |
| configs.cm.url | string | `""` | Argo CD's externally facing base URL (optional). Required when configuring SSO |
| configs.cmp.annotations | object | `{}` | Annotations to be added to argocd-cmp-cm configmap |
| configs.cmp.create | bool | `false` | Create the argocd-cmp-cm configmap |
| configs.cmp.plugins | object | `{}` | Plugin yaml files to be added to argocd-cmp-cm |
| configs.credentialTemplates | object | `{}` | Repository credentials to be used as Templates for other repos |
| configs.credentialTemplatesAnnotations | object | `{}` | Annotations to be added to `configs.credentialTemplates` Secret |
| configs.gpg.annotations | object | `{}` | Annotations to be added to argocd-gpg-keys-cm configmap |
| configs.gpg.keys | object | `{}` (See [values.yaml]) | [GnuPG] public keys to add to the keyring |
| configs.params."application.namespaces" | string | `""` | Enables [Applications in any namespace] |
| configs.params."applicationsetcontroller.enable.progressive.syncs" | bool | `false` | Enables use of the Progressive Syncs capability |
| configs.params."applicationsetcontroller.policy" | string | `"sync"` | Modify how application is synced between the generator and the cluster. One of: `sync`, `create-only`, `create-update`, `create-delete` |
| configs.params."controller.operation.processors" | int | `10` | Number of application operation processors |
| configs.params."controller.repo.server.timeout.seconds" | int | `60` | Repo server RPC call timeout seconds. |
| configs.params."controller.self.heal.timeout.seconds" | int | `5` | Specifies timeout between application self heal attempts |
| configs.params."controller.status.processors" | int | `20` | Number of application status processors |
| configs.params."otlp.address" | string | `""` | Open-Telemetry collector address: (e.g. "otel-collector:4317") |
| configs.params."reposerver.parallelism.limit" | int | `0` | Limit on number of concurrent manifests generate requests. Any value less the 1 means no limit. |
| configs.params."server.basehref" | string | `"/"` | Value for base href in index.html. Used if Argo CD is running behind reverse proxy under subpath different from / |
| configs.params."server.disable.auth" | bool | `false` | Disable Argo CD RBAC for user authentication |
| configs.params."server.enable.gzip" | bool | `true` | Enable GZIP compression |
| configs.params."server.insecure" | bool | `false` | Run server without TLS |
| configs.params."server.rootpath" | string | `""` | Used if Argo CD is running behind reverse proxy under subpath different from / |
| configs.params."server.staticassets" | string | `"/shared/app"` | Directory path that contains additional static assets |
| configs.params."server.x.frame.options" | string | `"sameorigin"` | Set X-Frame-Options header in HTTP responses to value. To disable, set to "". |
| configs.params.annotations | object | `{}` | Annotations to be added to the argocd-cmd-params-cm ConfigMap |
| configs.params.create | bool | `true` | Create the argocd-cmd-params-cm configmap If false, it is expected the configmap will be created by something else. |
| configs.rbac."policy.csv" | string | `''` (See [values.yaml]) | File containing user-defined policies and role definitions. |
| configs.rbac."policy.default" | string | `""` | The name of the default role which Argo CD will falls back to, when authorizing API requests (optional). If omitted or empty, users may be still be able to login, but will see no apps, projects, etc... |
| configs.rbac.annotations | object | `{}` | Annotations to be added to argocd-rbac-cm configmap |
| configs.rbac.create | bool | `true` | Create the argocd-rbac-cm configmap with ([Argo CD RBAC policy]) definitions. If false, it is expected the configmap will be created by something else. Argo CD will not work if there is no configmap created with the name above. |
| configs.rbac.scopes | string | `"[groups]"` | OIDC scopes to examine during rbac enforcement (in addition to `sub` scope). The scope value can be a string, or a list of strings. |
| configs.repositories | object | `{}` | Repositories list to be used by applications |
| configs.repositoriesAnnotations | object | `{}` | Annotations to be added to `configs.repositories` Secret |
| configs.secret.annotations | object | `{}` | Annotations to be added to argocd-secret |
| configs.secret.argocdServerAdminPassword | string | `""` | Bcrypt hashed admin password |
| configs.secret.argocdServerAdminPasswordMtime | string | `""` (defaults to current time) | Admin password modification time. Eg. `"2006-01-02T15:04:05Z"` |
| configs.secret.bitbucketServerSecret | string | `""` | Shared secret for authenticating BitbucketServer webhook events |
| configs.secret.bitbucketUUID | string | `""` | UUID for authenticating Bitbucket webhook events |
| configs.secret.createSecret | bool | `true` | Create the argocd-secret |
| configs.secret.extra | object | `{}` | add additional secrets to be added to argocd-secret |
| configs.secret.githubSecret | string | `""` | Shared secret for authenticating GitHub webhook events |
| configs.secret.gitlabSecret | string | `""` | Shared secret for authenticating GitLab webhook events |
| configs.secret.gogsSecret | string | `""` | Shared secret for authenticating Gogs webhook events |
| configs.secret.labels | object | `{}` | Labels to be added to argocd-secret |
| configs.ssh.annotations | object | `{}` | Annotations to be added to argocd-ssh-known-hosts-cm configmap |
| configs.ssh.extraHosts | string | `""` | Additional known hosts for private repositories |
| configs.ssh.knownHosts | string | See [values.yaml] | Known hosts to be added to the known host list by default. |
| configs.styles | string | `""` (See [values.yaml]) | Define custom [CSS styles] for your argo instance. This setting will automatically mount the provided CSS and reference it in the argo configuration. |
| configs.tls.annotations | object | `{}` | Annotations to be added to argocd-tls-certs-cm configmap |
| configs.tls.certificates | object | `{}` (See [values.yaml]) | TLS certificates for Git repositories |

## Argo CD Controller

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules to the deployment |
| controller.args | object | `{}` | DEPRECATED - Application controller commandline flags |
| controller.clusterRoleRules.enabled | bool | `false` | Enable custom rules for the application controller's ClusterRole resource |
| controller.clusterRoleRules.rules | list | `[]` | List of custom rules for the application controller's ClusterRole resource |
| controller.containerPorts.metrics | int | `8082` | Metrics container port |
| controller.containerSecurityContext | object | See [values.yaml] | Application controller container-level security context |
| controller.dnsConfig | object | `{}` | [DNS configuration] |
| controller.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for application controller pods |
| controller.env | list | `[]` | Environment variables to pass to application controller |
| controller.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to application controller |
| controller.extraArgs | list | `[]` | Additional command line arguments to pass to application controller |
| controller.extraContainers | list | `[]` | Additional containers to be added to the application controller pod |
| controller.hostNetwork | bool | `false` | Host Network for application controller pods |
| controller.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the application controller |
| controller.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the application controller |
| controller.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the application controller |
| controller.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| controller.initContainers | list | `[]` | Init containers to add to the application controller pod |
| controller.metrics.applicationLabels.enabled | bool | `false` | Enables additional labels in argocd_app_labels metric |
| controller.metrics.applicationLabels.labels | list | `[]` | Additional labels |
| controller.metrics.enabled | bool | `false` | Deploy metrics service |
| controller.metrics.rules.additionalLabels | object | `{}` | PrometheusRule labels |
| controller.metrics.rules.annotations | object | `{}` | PrometheusRule annotations |
| controller.metrics.rules.enabled | bool | `false` | Deploy a PrometheusRule for the application controller |
| controller.metrics.rules.namespace | string | `""` | PrometheusRule namespace |
| controller.metrics.rules.selector | object | `{}` | PrometheusRule selector |
| controller.metrics.rules.spec | list | `[]` | PrometheusRule.Spec for the application controller |
| controller.metrics.service.annotations | object | `{}` | Metrics service annotations |
| controller.metrics.service.clusterIP | string | `""` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| controller.metrics.service.labels | object | `{}` | Metrics service labels |
| controller.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| controller.metrics.service.servicePort | int | `8082` | Metrics service port |
| controller.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| controller.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| controller.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| controller.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| controller.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| controller.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| controller.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| controller.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| controller.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| controller.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| controller.name | string | `"application-controller"` | Application controller name string |
| controller.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| controller.pdb.annotations | object | `{}` | Annotations to be added to application controller pdb |
| controller.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the application controller |
| controller.pdb.labels | object | `{}` | Labels to be added to application controller pdb |
| controller.pdb.maxUnavailable | string | `""` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). |
| controller.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| controller.podAnnotations | object | `{}` | Annotations to be added to application controller pods |
| controller.podLabels | object | `{}` | Labels to be added to application controller pods |
| controller.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the application controller pods |
| controller.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| controller.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| controller.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| controller.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| controller.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| controller.replicas | int | `1` | The number of application controller pods to run. Additional replicas will cause sharding of managed clusters across number of replicas. |
| controller.resources | object | `{}` | Resource limits and requests for the application controller pods |
| controller.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| controller.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| controller.serviceAccount.create | bool | `true` | Create a service account for the application controller |
| controller.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| controller.serviceAccount.name | string | `"argocd-application-controller"` | Service account name |
| controller.statefulsetAnnotations | object | `{}` | Annotations for the application controller StatefulSet |
| controller.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| controller.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| controller.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to the application controller |
| controller.volumeMounts | list | `[]` | Additional volumeMounts to the application controller main container |
| controller.volumes | list | `[]` | Additional volumes to the application controller pod |

## Argo Repo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| repoServer.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules to the deployment |
| repoServer.autoscaling.behavior | object | `{}` | Configures the scaling behavior of the target in both Up and Down directions. |
| repoServer.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the repo server |
| repoServer.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the repo server [HPA] |
| repoServer.autoscaling.metrics | list | `[]` | Configures custom HPA metrics for the Argo CD repo server Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| repoServer.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the repo server [HPA] |
| repoServer.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the repo server [HPA] |
| repoServer.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the repo server [HPA] |
| repoServer.certificateSecret.annotations | object | `{}` | Annotations to be added to argocd-repo-server-tls secret |
| repoServer.certificateSecret.ca | string | `""` | Certificate authority. Required for self-signed certificates. |
| repoServer.certificateSecret.crt | string | `""` | Certificate data. Must contain SANs of Repo service (ie: argocd-repo-server, argocd-repo-server.argo-cd.svc) |
| repoServer.certificateSecret.enabled | bool | `false` | Create argocd-repo-server-tls secret |
| repoServer.certificateSecret.key | string | `""` | Certificate private key |
| repoServer.certificateSecret.labels | object | `{}` | Labels to be added to argocd-repo-server-tls secret |
| repoServer.clusterRoleRules.enabled | bool | `false` | Enable custom rules for the Repo server's Cluster Role resource |
| repoServer.clusterRoleRules.rules | list | `[]` | List of custom rules for the Repo server's Cluster Role resource |
| repoServer.containerPorts.metrics | int | `8084` | Metrics container port |
| repoServer.containerPorts.server | int | `8081` | Repo server container port |
| repoServer.containerSecurityContext | object | See [values.yaml] | Repo server container-level security context |
| repoServer.deploymentAnnotations | object | `{}` | Annotations to be added to repo server Deployment |
| repoServer.deploymentStrategy | object | `{}` | Deployment strategy to be added to the repo server Deployment |
| repoServer.dnsConfig | object | `{}` | [DNS configuration] |
| repoServer.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for Repo server pods |
| repoServer.env | list | `[]` | Environment variables to pass to repo server |
| repoServer.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to repo server |
| repoServer.extraArgs | list | `[]` | Additional command line arguments to pass to repo server |
| repoServer.extraContainers | list | `[]` | Additional containers to be added to the repo server pod |
| repoServer.hostNetwork | bool | `false` | Host Network for Repo server pods |
| repoServer.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the repo server |
| repoServer.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the repo server |
| repoServer.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the repo server |
| repoServer.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| repoServer.initContainers | list | `[]` | Init containers to add to the repo server pods |
| repoServer.lifecycle | object | `{}` | Specify postStart and preStop lifecycle hooks for your argo-repo-server container |
| repoServer.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| repoServer.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| repoServer.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| repoServer.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| repoServer.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| repoServer.metrics.enabled | bool | `false` | Deploy metrics service |
| repoServer.metrics.service.annotations | object | `{}` | Metrics service annotations |
| repoServer.metrics.service.clusterIP | string | `""` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| repoServer.metrics.service.labels | object | `{}` | Metrics service labels |
| repoServer.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| repoServer.metrics.service.servicePort | int | `8084` | Metrics service port |
| repoServer.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| repoServer.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| repoServer.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| repoServer.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| repoServer.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| repoServer.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| repoServer.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| repoServer.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| repoServer.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| repoServer.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| repoServer.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| repoServer.name | string | `"repo-server"` | Repo server name |
| repoServer.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| repoServer.pdb.annotations | object | `{}` | Annotations to be added to repo server pdb |
| repoServer.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the repo server |
| repoServer.pdb.labels | object | `{}` | Labels to be added to repo server pdb |
| repoServer.pdb.maxUnavailable | string | `""` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). |
| repoServer.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| repoServer.podAnnotations | object | `{}` | Annotations to be added to repo server pods |
| repoServer.podLabels | object | `{}` | Labels to be added to repo server pods |
| repoServer.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the repo server pods |
| repoServer.rbac | list | `[]` | Repo server rbac rules |
| repoServer.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| repoServer.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| repoServer.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| repoServer.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| repoServer.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| repoServer.replicas | int | `1` | The number of repo server pods to run |
| repoServer.resources | object | `{}` | Resource limits and requests for the repo server pods |
| repoServer.service.annotations | object | `{}` | Repo server service annotations |
| repoServer.service.labels | object | `{}` | Repo server service labels |
| repoServer.service.port | int | `8081` | Repo server service port |
| repoServer.service.portName | string | `"https-repo-server"` | Repo server service port name |
| repoServer.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| repoServer.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| repoServer.serviceAccount.create | bool | `true` | Create repo server service account |
| repoServer.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| repoServer.serviceAccount.name | string | `""` | Repo server service account name |
| repoServer.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| repoServer.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| repoServer.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to the repo server |
| repoServer.useEphemeralHelmWorkingDir | bool | `true` | Toggle the usage of a ephemeral Helm working directory |
| repoServer.volumeMounts | list | `[]` | Additional volumeMounts to the repo server main container |
| repoServer.volumes | list | `[]` | Additional volumes to the repo server pod |

## Argo Server

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server.GKEbackendConfig.enabled | bool | `false` | Enable BackendConfig custom resource for Google Kubernetes Engine |
| server.GKEbackendConfig.spec | object | `{}` | [BackendConfigSpec] |
| server.GKEfrontendConfig.enabled | bool | `false` | Enable FrontConfig custom resource for Google Kubernetes Engine |
| server.GKEfrontendConfig.spec | object | `{}` | [FrontendConfigSpec] |
| server.GKEmanagedCertificate.domains | list | `["argocd.example.com"]` | Domains for the Google Managed Certificate |
| server.GKEmanagedCertificate.enabled | bool | `false` | Enable ManagedCertificate custom resource for Google Kubernetes Engine. |
| server.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules to the deployment |
| server.autoscaling.behavior | object | `{}` | Configures the scaling behavior of the target in both Up and Down directions. |
| server.autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaler ([HPA]) for the Argo CD server |
| server.autoscaling.maxReplicas | int | `5` | Maximum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.metrics | list | `[]` | Configures custom HPA metrics for the Argo CD server Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| server.autoscaling.minReplicas | int | `1` | Minimum number of replicas for the Argo CD server [HPA] |
| server.autoscaling.targetCPUUtilizationPercentage | int | `50` | Average CPU utilization percentage for the Argo CD server [HPA] |
| server.autoscaling.targetMemoryUtilizationPercentage | int | `50` | Average memory utilization percentage for the Argo CD server [HPA] |
| server.certificate.additionalHosts | list | `[]` | Certificate Subject Alternate Names (SANs) |
| server.certificate.annotations | object | `{}` | Annotations to be applied to the Server Certificate |
| server.certificate.domain | string | `"argocd.example.com"` | Certificate primary domain (commonName) |
| server.certificate.duration | string | `""` (defaults to 2160h = 90d if not specified) | The requested 'duration' (i.e. lifetime) of the certificate. |
| server.certificate.enabled | bool | `false` | Deploy a Certificate resource (requires cert-manager) |
| server.certificate.issuer.group | string | `""` | Certificate issuer group. Set if using an external issuer. Eg. `cert-manager.io` |
| server.certificate.issuer.kind | string | `""` | Certificate issuer kind. Either `Issuer` or `ClusterIssuer` |
| server.certificate.issuer.name | string | `""` | Certificate issuer name. Eg. `letsencrypt` |
| server.certificate.privateKey.algorithm | string | `"RSA"` | Algorithm used to generate certificate private key. One of: `RSA`, `Ed25519` or `ECDSA` |
| server.certificate.privateKey.encoding | string | `"PKCS1"` | The private key cryptography standards (PKCS) encoding for private key. Either: `PCKS1` or `PKCS8` |
| server.certificate.privateKey.rotationPolicy | string | `"Never"` | Rotation policy of private key when certificate is re-issued. Either: `Never` or `Always` |
| server.certificate.privateKey.size | int | `2048` | Key bit size of the private key. If algorithm is set to `Ed25519`, size is ignored. |
| server.certificate.renewBefore | string | `""` (defaults to 360h = 15d if not specified) | How long before the expiry a certificate should be renewed. |
| server.certificate.secretName | string | `"argocd-server-tls"` | The name of the Secret that will be automatically created and managed by this Certificate resource |
| server.certificate.usages | list | `[]` | Usages for the certificate |
| server.certificateSecret.annotations | object | `{}` | Annotations to be added to argocd-server-tls secret |
| server.certificateSecret.crt | string | `""` | Certificate data |
| server.certificateSecret.enabled | bool | `false` | Create argocd-server-tls secret |
| server.certificateSecret.key | string | `""` | Private Key of the certificate |
| server.certificateSecret.labels | object | `{}` | Labels to be added to argocd-server-tls secret |
| server.containerPorts.metrics | int | `8083` | Metrics container port |
| server.containerPorts.server | int | `8080` | Server container port |
| server.containerSecurityContext | object | See [values.yaml] | Server container-level security context |
| server.deploymentAnnotations | object | `{}` | Annotations to be added to server Deployment |
| server.deploymentStrategy | object | `{}` | Deployment strategy to be added to the server Deployment |
| server.dnsConfig | object | `{}` | [DNS configuration] |
| server.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for Server pods |
| server.env | list | `[]` | Environment variables to pass to Argo CD server |
| server.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to Argo CD server |
| server.extensions.containerSecurityContext | object | See [values.yaml] | Server UI extensions container-level security context |
| server.extensions.enabled | bool | `false` | Enable support for Argo UI extensions |
| server.extensions.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for extensions |
| server.extensions.image.repository | string | `"ghcr.io/argoproj-labs/argocd-extensions"` | Repository to use for extensions image |
| server.extensions.image.tag | string | `"v0.2.1"` | Tag to use for extensions image |
| server.extensions.resources | object | `{}` | Resource limits and requests for the argocd-extensions container |
| server.extraArgs | list | `[]` | Additional command line arguments to pass to Argo CD server |
| server.extraContainers | list | `[]` | Additional containers to be added to the server pod |
| server.hostNetwork | bool | `false` | Host Network for Server pods |
| server.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the Argo CD server |
| server.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the Argo CD server |
| server.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the Argo CD server |
| server.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| server.ingress.annotations | object | `{}` | Additional ingress annotations |
| server.ingress.enabled | bool | `false` | Enable an ingress resource for the Argo CD server |
| server.ingress.extraPaths | list | `[]` | Additional ingress paths |
| server.ingress.hosts | list | `[]` | List of ingress hosts |
| server.ingress.https | bool | `false` | Uses `server.service.servicePortHttps` instead `server.service.servicePortHttp` |
| server.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| server.ingress.labels | object | `{}` | Additional ingress labels |
| server.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| server.ingress.paths | list | `["/"]` | List of ingress paths |
| server.ingress.tls | list | `[]` | Ingress TLS configuration |
| server.ingressGrpc.annotations | object | `{}` | Additional ingress annotations for dedicated [gRPC-ingress] |
| server.ingressGrpc.awsALB.backendProtocolVersion | string | `"HTTP2"` | Backend protocol version for the AWS ALB gRPC service |
| server.ingressGrpc.awsALB.serviceType | string | `"NodePort"` | Service type for the AWS ALB gRPC service |
| server.ingressGrpc.enabled | bool | `false` | Enable an ingress resource for the Argo CD server for dedicated [gRPC-ingress] |
| server.ingressGrpc.extraPaths | list | `[]` | Additional ingress paths for dedicated [gRPC-ingress] |
| server.ingressGrpc.hosts | list | `[]` | List of ingress hosts for dedicated [gRPC-ingress] |
| server.ingressGrpc.https | bool | `false` | Uses `server.service.servicePortHttps` instead `server.service.servicePortHttp` |
| server.ingressGrpc.ingressClassName | string | `""` | Defines which ingress controller will implement the resource [gRPC-ingress] |
| server.ingressGrpc.isAWSALB | bool | `false` | Setup up gRPC ingress to work with an AWS ALB |
| server.ingressGrpc.labels | object | `{}` | Additional ingress labels for dedicated [gRPC-ingress] |
| server.ingressGrpc.pathType | string | `"Prefix"` | Ingress path type for dedicated [gRPC-ingress]. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| server.ingressGrpc.paths | list | `["/"]` | List of ingress paths for dedicated [gRPC-ingress] |
| server.ingressGrpc.tls | list | `[]` | Ingress TLS configuration for dedicated [gRPC-ingress] |
| server.initContainers | list | `[]` | Init containers to add to the server pod |
| server.lifecycle | object | `{}` | Specify postStart and preStop lifecycle hooks for your argo-cd-server container |
| server.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| server.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| server.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| server.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| server.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| server.metrics.enabled | bool | `false` | Deploy metrics service |
| server.metrics.service.annotations | object | `{}` | Metrics service annotations |
| server.metrics.service.clusterIP | string | `""` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| server.metrics.service.labels | object | `{}` | Metrics service labels |
| server.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| server.metrics.service.servicePort | int | `8083` | Metrics service port |
| server.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| server.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| server.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| server.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| server.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| server.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| server.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| server.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| server.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| server.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| server.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| server.name | string | `"server"` | Argo CD server name |
| server.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| server.pdb.annotations | object | `{}` | Annotations to be added to Argo CD server pdb |
| server.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the Argo CD server |
| server.pdb.labels | object | `{}` | Labels to be added to Argo CD server pdb |
| server.pdb.maxUnavailable | string | `""` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). |
| server.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| server.podAnnotations | object | `{}` | Annotations to be added to server pods |
| server.podLabels | object | `{}` | Labels to be added to server pods |
| server.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the Argo CD server pods |
| server.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| server.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| server.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| server.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| server.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| server.replicas | int | `1` | The number of server pods to run |
| server.resources | object | `{}` | Resource limits and requests for the Argo CD server |
| server.route.annotations | object | `{}` | Openshift Route annotations |
| server.route.enabled | bool | `false` | Enable an OpenShift Route for the Argo CD server |
| server.route.hostname | string | `""` | Hostname of OpenShift Route |
| server.route.termination_policy | string | `"None"` | Termination policy of Openshift Route |
| server.route.termination_type | string | `"passthrough"` | Termination type of Openshift Route |
| server.service.annotations | object | `{}` | Server service annotations |
| server.service.externalIPs | list | `[]` | Server service external IPs |
| server.service.externalTrafficPolicy | string | `""` | Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints |
| server.service.labels | object | `{}` | Server service labels |
| server.service.loadBalancerIP | string | `""` | LoadBalancer will get created with the IP specified in this field |
| server.service.loadBalancerSourceRanges | list | `[]` | Source IP ranges to allow access to service from |
| server.service.nodePortHttp | int | `30080` | Server service http port for NodePort service type (only if `server.service.type` is set to "NodePort") |
| server.service.nodePortHttps | int | `30443` | Server service https port for NodePort service type (only if `server.service.type` is set to "NodePort") |
| server.service.servicePortHttp | int | `80` | Server service http port |
| server.service.servicePortHttpName | string | `"http"` | Server service http port name, can be used to route traffic via istio |
| server.service.servicePortHttps | int | `443` | Server service https port |
| server.service.servicePortHttpsName | string | `"https"` | Server service https port name, can be used to route traffic via istio |
| server.service.sessionAffinity | string | `""` | Used to maintain session affinity. Supports `ClientIP` and `None` |
| server.service.type | string | `"ClusterIP"` | Server service type |
| server.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| server.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| server.serviceAccount.create | bool | `true` | Create server service account |
| server.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| server.serviceAccount.name | string | `"argocd-server"` | Server service account name |
| server.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| server.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| server.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to the Argo CD server |
| server.volumeMounts | list | `[]` | Additional volumeMounts to the server main container |
| server.volumes | list | `[]` | Additional volumes to the server pod |

### Using AWS ALB Ingress Controller With GRPC

If you are using an AWS ALB Ingress controller, you will need to set `server.ingressGrpc.isAWSALB` to `true`. This will create a second service with the annotation `alb.ingress.kubernetes.io/backend-protocol-version: HTTP2` and modify the server ingress to add a condition annotation to route GRPC traffic to the new service.

Example:

```yaml
server:
  ingress:
    enabled: true
    annotations:
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internal
      alb.ingress.kubernetes.io/target-type: ip
  ingressGrpc:
    enabled: true
    isAWSALB: true
    awsALB:
      serviceType: ClusterIP
```

## Dex

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dex.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules to the deployment |
| dex.certificateSecret.annotations | object | `{}` | Annotations to be added to argocd-dex-server-tls secret |
| dex.certificateSecret.ca | string | `""` | Certificate authority. Required for self-signed certificates. |
| dex.certificateSecret.crt | string | `""` | Certificate data. Must contain SANs of Dex service (ie: argocd-dex-server, argocd-dex-server.argo-cd.svc) |
| dex.certificateSecret.enabled | bool | `false` | Create argocd-dex-server-tls secret |
| dex.certificateSecret.key | string | `""` | Certificate private key |
| dex.certificateSecret.labels | object | `{}` | Labels to be added to argocd-dex-server-tls secret |
| dex.containerPorts.grpc | int | `5557` | gRPC container port |
| dex.containerPorts.http | int | `5556` | HTTP container port |
| dex.containerPorts.metrics | int | `5558` | Metrics container port |
| dex.containerSecurityContext | object | See [values.yaml] | Dex container-level security context |
| dex.deploymentAnnotations | object | `{}` | Annotations to be added to the Dex server Deployment |
| dex.deploymentStrategy | object | `{}` | Deployment strategy to be added to the Dex server Deployment |
| dex.dnsConfig | object | `{}` | [DNS configuration] |
| dex.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for Dex server pods |
| dex.enabled | bool | `true` | Enable dex |
| dex.env | list | `[]` | Environment variables to pass to the Dex server |
| dex.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the Dex server |
| dex.extraArgs | list | `[]` | Additional command line arguments to pass to the Dex server |
| dex.extraContainers | list | `[]` | Additional containers to be added to the dex pod |
| dex.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Dex imagePullPolicy |
| dex.image.repository | string | `"ghcr.io/dexidp/dex"` | Dex image repository |
| dex.image.tag | string | `"v2.37.0"` | Dex image tag |
| dex.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| dex.initContainers | list | `[]` | Init containers to add to the dex pod |
| dex.initImage.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Argo CD init image imagePullPolicy |
| dex.initImage.repository | string | `""` (defaults to global.image.repository) | Argo CD init image repository |
| dex.initImage.resources | object | `{}` (defaults to dex.resources) | Argo CD init image resources |
| dex.initImage.tag | string | `""` (defaults to global.image.tag) | Argo CD init image tag |
| dex.livenessProbe.enabled | bool | `false` | Enable Kubernetes liveness probe for Dex >= 2.28.0 |
| dex.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| dex.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| dex.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| dex.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| dex.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| dex.logFormat | string | `""` (defaults to global.logging.format) | Dex log format. Either `text` or `json` |
| dex.logLevel | string | `""` (defaults to global.logging.level) | Dex log level. One of: `debug`, `info`, `warn`, `error` |
| dex.metrics.enabled | bool | `false` | Deploy metrics service |
| dex.metrics.service.annotations | object | `{}` | Metrics service annotations |
| dex.metrics.service.labels | object | `{}` | Metrics service labels |
| dex.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| dex.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| dex.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| dex.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| dex.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| dex.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| dex.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| dex.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| dex.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| dex.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| dex.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| dex.name | string | `"dex-server"` | Dex name |
| dex.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| dex.pdb.annotations | object | `{}` | Annotations to be added to Dex server pdb |
| dex.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the Dex server |
| dex.pdb.labels | object | `{}` | Labels to be added to Dex server pdb |
| dex.pdb.maxUnavailable | string | `""` | Number of pods that are unavailble after eviction as number or percentage (eg.: 50%). |
| dex.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| dex.podAnnotations | object | `{}` | Annotations to be added to the Dex server pods |
| dex.podLabels | object | `{}` | Labels to be added to the Dex server pods |
| dex.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the dex pods |
| dex.readinessProbe.enabled | bool | `false` | Enable Kubernetes readiness probe for Dex >= 2.28.0 |
| dex.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| dex.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| dex.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| dex.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| dex.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| dex.resources | object | `{}` | Resource limits and requests for dex |
| dex.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| dex.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| dex.serviceAccount.create | bool | `true` | Create dex service account |
| dex.serviceAccount.name | string | `"argocd-dex-server"` | Dex service account name |
| dex.servicePortGrpc | int | `5557` | Service port for gRPC access |
| dex.servicePortGrpcName | string | `"grpc"` | Service port name for gRPC access |
| dex.servicePortHttp | int | `5556` | Service port for HTTP access |
| dex.servicePortHttpName | string | `"http"` | Service port name for HTTP access |
| dex.servicePortMetrics | int | `5558` | Service port for metrics access |
| dex.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| dex.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| dex.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to dex |
| dex.volumeMounts | list | `[]` | Additional volumeMounts to the dex main container |
| dex.volumes | list | `[]` | Additional volumes to the dex pod |

## Redis

### Option 1 - Single Redis instance (default option)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules to the deployment |
| redis.containerPorts.metrics | int | `9121` | Metrics container port |
| redis.containerPorts.redis | int | `6379` | Redis container port |
| redis.containerSecurityContext | object | See [values.yaml] | Redis container-level security context |
| redis.deploymentAnnotations | object | `{}` | Annotations to be added to the Redis server Deployment |
| redis.dnsConfig | object | `{}` | [DNS configuration] |
| redis.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for Redis server pods |
| redis.enabled | bool | `true` | Enable redis |
| redis.env | list | `[]` | Environment variables to pass to the Redis server |
| redis.envFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the Redis server |
| redis.exporter.containerSecurityContext | object | See [values.yaml] | Redis exporter security context |
| redis.exporter.enabled | bool | `false` | Enable Prometheus redis-exporter sidecar |
| redis.exporter.env | list | `[]` | Environment variables to pass to the Redis exporter |
| redis.exporter.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the redis-exporter |
| redis.exporter.image.repository | string | `"public.ecr.aws/bitnami/redis-exporter"` | Repository to use for the redis-exporter |
| redis.exporter.image.tag | string | `"1.53.0"` | Tag to use for the redis-exporter |
| redis.exporter.resources | object | `{}` | Resource limits and requests for redis-exporter sidecar |
| redis.extraArgs | list | `[]` | Additional command line arguments to pass to redis-server |
| redis.extraContainers | list | `[]` | Additional containers to be added to the redis pod |
| redis.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Redis image pull policy |
| redis.image.repository | string | `"public.ecr.aws/docker/library/redis"` | Redis repository |
| redis.image.tag | string | `"7.0.13-alpine"` | Redis tag |
| redis.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| redis.initContainers | list | `[]` | Init containers to add to the redis pod |
| redis.metrics.enabled | bool | `false` | Deploy metrics service |
| redis.metrics.service.annotations | object | `{}` | Metrics service annotations |
| redis.metrics.service.clusterIP | string | `"None"` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| redis.metrics.service.labels | object | `{}` | Metrics service labels |
| redis.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| redis.metrics.service.servicePort | int | `9121` | Metrics service port |
| redis.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| redis.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| redis.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| redis.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| redis.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| redis.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| redis.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| redis.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| redis.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| redis.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| redis.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| redis.name | string | `"redis"` | Redis name |
| redis.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| redis.pdb.annotations | object | `{}` | Annotations to be added to Redis pdb |
| redis.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the Redis |
| redis.pdb.labels | object | `{}` | Labels to be added to Redis pdb |
| redis.pdb.maxUnavailable | string | `""` | Number of pods that are unavailble after eviction as number or percentage (eg.: 50%). |
| redis.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| redis.podAnnotations | object | `{}` | Annotations to be added to the Redis server pods |
| redis.podLabels | object | `{}` | Labels to be added to the Redis server pods |
| redis.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for redis pods |
| redis.resources | object | `{}` | Resource limits and requests for redis |
| redis.securityContext | object | See [values.yaml] | Redis pod-level security context |
| redis.service.annotations | object | `{}` | Redis service annotations |
| redis.service.labels | object | `{}` | Additional redis service labels |
| redis.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| redis.serviceAccount.automountServiceAccountToken | bool | `false` | Automount API credentials for the Service Account |
| redis.serviceAccount.create | bool | `false` | Create a service account for the redis pod |
| redis.serviceAccount.name | string | `""` | Service account name for redis pod |
| redis.servicePort | int | `6379` | Redis service port |
| redis.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| redis.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| redis.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to redis |
| redis.volumeMounts | list | `[]` | Additional volumeMounts to the redis container |
| redis.volumes | list | `[]` | Additional volumes to the redis pod |

### Option 2 - Redis HA

This option uses the following third-party chart to bootstrap a clustered Redis: https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha.
For all available configuration options, please read upstream README and/or chart source.
The main options are listed here:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis-ha.additionalAffinities | object | `{}` | Additional affinities to add to the Redis server pods. |
| redis-ha.affinity | string | `""` | Assign custom [affinity] rules to the Redis pods. |
| redis-ha.containerSecurityContext | object | See [values.yaml] | Redis HA statefulset container-level security context |
| redis-ha.enabled | bool | `false` | Enables the Redis HA subchart and disables the custom Redis single node deployment |
| redis-ha.exporter.enabled | bool | `false` | Enable Prometheus redis-exporter sidecar |
| redis-ha.exporter.image | string | `"public.ecr.aws/bitnami/redis-exporter"` | Repository to use for the redis-exporter |
| redis-ha.exporter.tag | string | `"1.53.0"` | Tag to use for the redis-exporter |
| redis-ha.haproxy.additionalAffinities | object | `{}` | Additional affinities to add to the haproxy pods. |
| redis-ha.haproxy.affinity | string | `""` | Assign custom [affinity] rules to the haproxy pods. |
| redis-ha.haproxy.containerSecurityContext | object | See [values.yaml] | HAProxy container-level security context |
| redis-ha.haproxy.enabled | bool | `true` | Enabled HAProxy LoadBalancing/Proxy |
| redis-ha.haproxy.hardAntiAffinity | bool | `true` | Whether the haproxy pods should be forced to run on separate nodes. |
| redis-ha.haproxy.metrics.enabled | bool | `true` | HAProxy enable prometheus metric scraping |
| redis-ha.haproxy.tolerations | list | `[]` | [Tolerations] for use with node taints for haproxy pods. |
| redis-ha.hardAntiAffinity | bool | `true` | Whether the Redis server pods should be forced to run on separate nodes. |
| redis-ha.image.repository | string | `"redis"` | Redis repository |
| redis-ha.image.tag | string | `"7.0.13-alpine"` | Redis tag |
| redis-ha.persistentVolume.enabled | bool | `false` | Configures persistence on Redis nodes |
| redis-ha.redis.config | object | See [values.yaml] | Any valid redis config options in this section will be applied to each server (see `redis-ha` chart) |
| redis-ha.redis.config.save | string | `'""'` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled |
| redis-ha.redis.masterGroupName | string | `"argocd"` | Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated |
| redis-ha.tolerations | list | `[]` | [Tolerations] for use with node taints for Redis pods. |
| redis-ha.topologySpreadConstraints | object | `{"enabled":false,"maxSkew":"","topologyKey":"","whenUnsatisfiable":""}` | Assign custom [TopologySpreadConstraints] rules to the Redis pods. |
| redis-ha.topologySpreadConstraints.enabled | bool | `false` | Enable Redis HA topology spread constraints |
| redis-ha.topologySpreadConstraints.maxSkew | string | `""` (defaults to `1`) | Max skew of pods tolerated |
| redis-ha.topologySpreadConstraints.topologyKey | string | `""` (defaults to `topology.kubernetes.io/zone`) | Topology key for spread |
| redis-ha.topologySpreadConstraints.whenUnsatisfiable | string | `""` (defaults to `ScheduleAnyway`) | Enforcement policy, hard or soft |
| redis-ha.exporter.image | string | `nil` (follows subchart default) | Exporter image |
| redis-ha.exporter.tag | string | `nil` (follows subchart default) | Exporter tag |
| redis-ha.haproxy.image.repository | string | `nil` (follows subchart default) | HAProxy Image Repository |
| redis-ha.haproxy.image.tag | string | `nil` (follows subchart default) | HAProxy Image Tag |
| redis-ha.image.repository | string | `nil` (follows subchart default) | Redis image repository |

### Option 3 - External Redis

If you want to use an existing Redis (eg. a managed service from a cloud provider), you can use these parameters:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis credentials (must contain key `redis-password`). When it's set, the `externalRedis.password` parameter is ignored |
| externalRedis.host | string | `""` | External Redis server host |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.secretAnnotations | object | `{}` | External Redis Secret annotations |
| externalRedis.username | string | `""` | External Redis username |

## ApplicationSet

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| applicationSet.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules |
| applicationSet.args | object | `{}` | DEPRECATED - ApplicationSet controller command line flags |
| applicationSet.certificate.additionalHosts | list | `[]` | Certificate Subject Alternate Names (SANs) |
| applicationSet.certificate.annotations | object | `{}` | Annotations to be applied to the ApplicationSet Certificate |
| applicationSet.certificate.domain | string | `"argocd.example.com"` | Certificate primary domain (commonName) |
| applicationSet.certificate.duration | string | `""` (defaults to 2160h = 90d if not specified) | The requested 'duration' (i.e. lifetime) of the certificate. |
| applicationSet.certificate.enabled | bool | `false` | Deploy a Certificate resource (requires cert-manager) |
| applicationSet.certificate.issuer.group | string | `""` | Certificate issuer group. Set if using an external issuer. Eg. `cert-manager.io` |
| applicationSet.certificate.issuer.kind | string | `""` | Certificate issuer kind. Either `Issuer` or `ClusterIssuer` |
| applicationSet.certificate.issuer.name | string | `""` | Certificate issuer name. Eg. `letsencrypt` |
| applicationSet.certificate.privateKey.algorithm | string | `"RSA"` | Algorithm used to generate certificate private key. One of: `RSA`, `Ed25519` or `ECDSA` |
| applicationSet.certificate.privateKey.encoding | string | `"PKCS1"` | The private key cryptography standards (PKCS) encoding for private key. Either: `PCKS1` or `PKCS8` |
| applicationSet.certificate.privateKey.rotationPolicy | string | `"Never"` | Rotation policy of private key when certificate is re-issued. Either: `Never` or `Always` |
| applicationSet.certificate.privateKey.size | int | `2048` | Key bit size of the private key. If algorithm is set to `Ed25519`, size is ignored. |
| applicationSet.certificate.renewBefore | string | `""` (defaults to 360h = 15d if not specified) | How long before the expiry a certificate should be renewed. |
| applicationSet.certificate.secretName | string | `"argocd-application-controller-tls"` | The name of the Secret that will be automatically created and managed by this Certificate resource |
| applicationSet.containerPorts.metrics | int | `8080` | Metrics container port |
| applicationSet.containerPorts.probe | int | `8081` | Probe container port |
| applicationSet.containerPorts.webhook | int | `7000` | Webhook container port |
| applicationSet.containerSecurityContext | object | See [values.yaml] | ApplicationSet controller container-level security context |
| applicationSet.deploymentAnnotations | object | `{}` | Annotations to be added to ApplicationSet controller Deployment |
| applicationSet.deploymentStrategy | object | `{}` | Deployment strategy to be added to the ApplicationSet controller Deployment |
| applicationSet.dnsConfig | object | `{}` | [DNS configuration] |
| applicationSet.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for ApplicationSet controller pods |
| applicationSet.enabled | bool | `true` | Enable ApplicationSet controller |
| applicationSet.extraArgs | list | `[]` | List of extra cli args to add |
| applicationSet.extraContainers | list | `[]` | Additional containers to be added to the ApplicationSet controller pod |
| applicationSet.extraEnv | list | `[]` | Environment variables to pass to the ApplicationSet controller |
| applicationSet.extraEnvFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the ApplicationSet controller |
| applicationSet.extraVolumeMounts | list | `[]` | List of extra mounts to add (normally used with extraVolumes) |
| applicationSet.extraVolumes | list | `[]` | List of extra volumes to add |
| applicationSet.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the ApplicationSet controller |
| applicationSet.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the ApplicationSet controller |
| applicationSet.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the ApplicationSet controller |
| applicationSet.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | If defined, uses a Secret to pull an image from a private Docker registry or repository. |
| applicationSet.initContainers | list | `[]` | Init containers to add to the ApplicationSet controller pod |
| applicationSet.livenessProbe.enabled | bool | `false` | Enable Kubernetes liveness probe for ApplicationSet controller |
| applicationSet.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| applicationSet.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| applicationSet.livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| applicationSet.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| applicationSet.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| applicationSet.metrics.enabled | bool | `false` | Deploy metrics service |
| applicationSet.metrics.service.annotations | object | `{}` | Metrics service annotations |
| applicationSet.metrics.service.clusterIP | string | `""` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| applicationSet.metrics.service.labels | object | `{}` | Metrics service labels |
| applicationSet.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| applicationSet.metrics.service.servicePort | int | `8080` | Metrics service port |
| applicationSet.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| applicationSet.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| applicationSet.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| applicationSet.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| applicationSet.metrics.serviceMonitor.interval | string | `"30s"` | Prometheus ServiceMonitor interval |
| applicationSet.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| applicationSet.metrics.serviceMonitor.namespace | string | `""` | Prometheus ServiceMonitor namespace |
| applicationSet.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| applicationSet.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| applicationSet.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| applicationSet.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| applicationSet.name | string | `"applicationset-controller"` | ApplicationSet controller name string |
| applicationSet.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| applicationSet.pdb.annotations | object | `{}` | Annotations to be added to ApplicationSet controller pdb |
| applicationSet.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the ApplicationSet controller |
| applicationSet.pdb.labels | object | `{}` | Labels to be added to ApplicationSet controller pdb |
| applicationSet.pdb.maxUnavailable | string | `""` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). |
| applicationSet.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| applicationSet.podAnnotations | object | `{}` | Annotations for the ApplicationSet controller pods |
| applicationSet.podLabels | object | `{}` | Labels for the ApplicationSet controller pods |
| applicationSet.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the ApplicationSet controller pods |
| applicationSet.readinessProbe.enabled | bool | `false` | Enable Kubernetes liveness probe for ApplicationSet controller |
| applicationSet.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded |
| applicationSet.readinessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before [probe] is initiated |
| applicationSet.readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe] |
| applicationSet.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed |
| applicationSet.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out |
| applicationSet.replicas | int | `1` | The number of ApplicationSet controller pods to run |
| applicationSet.resources | object | `{}` | Resource limits and requests for the ApplicationSet controller pods. |
| applicationSet.service.annotations | object | `{}` | ApplicationSet service annotations |
| applicationSet.service.labels | object | `{}` | ApplicationSet service labels |
| applicationSet.service.port | int | `7000` | ApplicationSet service port |
| applicationSet.service.portName | string | `"webhook"` | ApplicationSet service port name |
| applicationSet.service.type | string | `"ClusterIP"` | ApplicationSet service type |
| applicationSet.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| applicationSet.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| applicationSet.serviceAccount.create | bool | `true` | Create ApplicationSet controller service account |
| applicationSet.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| applicationSet.serviceAccount.name | string | `"argocd-applicationset-controller"` | ApplicationSet controller service account name |
| applicationSet.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| applicationSet.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| applicationSet.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to the ApplicationSet controller |
| applicationSet.webhook.ingress.annotations | object | `{}` | Additional ingress annotations |
| applicationSet.webhook.ingress.enabled | bool | `false` | Enable an ingress resource for Webhooks |
| applicationSet.webhook.ingress.extraPaths | list | `[]` | Additional ingress paths |
| applicationSet.webhook.ingress.hosts | list | `[]` | List of ingress hosts |
| applicationSet.webhook.ingress.ingressClassName | string | `""` | Defines which ingress ApplicationSet controller will implement the resource |
| applicationSet.webhook.ingress.labels | object | `{}` | Additional ingress labels |
| applicationSet.webhook.ingress.pathType | string | `"Prefix"` | Ingress path type. One of `Exact`, `Prefix` or `ImplementationSpecific` |
| applicationSet.webhook.ingress.paths | list | `["/api/webhook"]` | List of ingress paths |
| applicationSet.webhook.ingress.tls | list | `[]` | Ingress TLS configuration |

## Notifications

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| notifications.affinity | object | `{}` (defaults to global.affinity preset) | Assign custom [affinity] rules |
| notifications.argocdUrl | string | `nil` | Argo CD dashboard url; used in place of {{.context.argocdUrl}} in templates |
| notifications.clusterRoleRules.rules | list | `[]` | List of custom rules for the notifications controller's ClusterRole resource |
| notifications.cm.create | bool | `true` | Whether helm chart creates notifications controller config map |
| notifications.containerPorts.metrics | int | `9001` | Metrics container port |
| notifications.containerSecurityContext | object | See [values.yaml] | Notification controller container-level security Context |
| notifications.context | object | `{}` | Define user-defined context |
| notifications.deploymentAnnotations | object | `{}` | Annotations to be applied to the notifications controller Deployment |
| notifications.deploymentStrategy | object | `{"type":"Recreate"}` | Deployment strategy to be added to the notifications controller Deployment |
| notifications.dnsConfig | object | `{}` | [DNS configuration] |
| notifications.dnsPolicy | string | `"ClusterFirst"` | Alternative DNS policy for notifications controller Pods |
| notifications.enabled | bool | `true` | Enable notifications controller |
| notifications.extraArgs | list | `[]` | Extra arguments to provide to the notifications controller |
| notifications.extraContainers | list | `[]` | Additional containers to be added to the notifications controller pod |
| notifications.extraEnv | list | `[]` | Additional container environment variables |
| notifications.extraEnvFrom | list | `[]` (See [values.yaml]) | envFrom to pass to the notifications controller |
| notifications.extraVolumeMounts | list | `[]` | List of extra mounts to add (normally used with extraVolumes) |
| notifications.extraVolumes | list | `[]` | List of extra volumes to add |
| notifications.image.imagePullPolicy | string | `""` (defaults to global.image.imagePullPolicy) | Image pull policy for the notifications controller |
| notifications.image.repository | string | `""` (defaults to global.image.repository) | Repository to use for the notifications controller |
| notifications.image.tag | string | `""` (defaults to global.image.tag) | Tag to use for the notifications controller |
| notifications.imagePullSecrets | list | `[]` (defaults to global.imagePullSecrets) | Secrets with credentials to pull images from a private registry |
| notifications.initContainers | list | `[]` | Init containers to add to the notifications controller pod |
| notifications.logFormat | string | `""` (defaults to global.logging.format) | Notifications controller log format. Either `text` or `json` |
| notifications.logLevel | string | `""` (defaults to global.logging.level) | Notifications controller log level. One of: `debug`, `info`, `warn`, `error` |
| notifications.metrics.enabled | bool | `false` | Enables prometheus metrics server |
| notifications.metrics.port | int | `9001` | Metrics port |
| notifications.metrics.service.annotations | object | `{}` | Metrics service annotations |
| notifications.metrics.service.clusterIP | string | `""` | Metrics service clusterIP. `None` makes a "headless service" (no virtual IP) |
| notifications.metrics.service.labels | object | `{}` | Metrics service labels |
| notifications.metrics.service.portName | string | `"http-metrics"` | Metrics service port name |
| notifications.metrics.service.type | string | `"ClusterIP"` | Metrics service type |
| notifications.metrics.serviceMonitor.additionalLabels | object | `{}` | Prometheus ServiceMonitor labels |
| notifications.metrics.serviceMonitor.annotations | object | `{}` | Prometheus ServiceMonitor annotations |
| notifications.metrics.serviceMonitor.enabled | bool | `false` | Enable a prometheus ServiceMonitor |
| notifications.metrics.serviceMonitor.metricRelabelings | list | `[]` | Prometheus [MetricRelabelConfigs] to apply to samples before ingestion |
| notifications.metrics.serviceMonitor.relabelings | list | `[]` | Prometheus [RelabelConfigs] to apply to samples before scraping |
| notifications.metrics.serviceMonitor.scheme | string | `""` | Prometheus ServiceMonitor scheme |
| notifications.metrics.serviceMonitor.selector | object | `{}` | Prometheus ServiceMonitor selector |
| notifications.metrics.serviceMonitor.tlsConfig | object | `{}` | Prometheus ServiceMonitor tlsConfig |
| notifications.name | string | `"notifications-controller"` | Notifications controller name string |
| notifications.nodeSelector | object | `{}` (defaults to global.nodeSelector) | [Node selector] |
| notifications.notifiers | object | See [values.yaml] | Configures notification services such as slack, email or custom webhook |
| notifications.pdb.annotations | object | `{}` | Annotations to be added to notifications controller pdb |
| notifications.pdb.enabled | bool | `false` | Deploy a [PodDisruptionBudget] for the notifications controller |
| notifications.pdb.labels | object | `{}` | Labels to be added to notifications controller pdb |
| notifications.pdb.maxUnavailable | string | `""` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). |
| notifications.pdb.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| notifications.podAnnotations | object | `{}` | Annotations to be applied to the notifications controller Pods |
| notifications.podLabels | object | `{}` | Labels to be applied to the notifications controller Pods |
| notifications.priorityClassName | string | `""` (defaults to global.priorityClassName) | Priority class for the notifications controller pods |
| notifications.resources | object | `{}` | Resource limits and requests for the notifications controller |
| notifications.secret.annotations | object | `{}` | key:value pairs of annotations to be added to the secret |
| notifications.secret.create | bool | `true` | Whether helm chart creates notifications controller secret |
| notifications.secret.items | object | `{}` | Generic key:value pairs to be inserted into the secret |
| notifications.secret.labels | object | `{}` | key:value pairs of labels to be added to the secret |
| notifications.serviceAccount.annotations | object | `{}` | Annotations applied to created service account |
| notifications.serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for the Service Account |
| notifications.serviceAccount.create | bool | `true` | Create notifications controller service account |
| notifications.serviceAccount.labels | object | `{}` | Labels applied to created service account |
| notifications.serviceAccount.name | string | `"argocd-notifications-controller"` | Notification controller service account name |
| notifications.subscriptions | list | `[]` | Contains centrally managed global application subscriptions |
| notifications.templates | object | `{}` | The notification template is used to generate the notification content |
| notifications.terminationGracePeriodSeconds | int | `30` | terminationGracePeriodSeconds for container lifecycle hook |
| notifications.tolerations | list | `[]` (defaults to global.tolerations) | [Tolerations] for use with node taints |
| notifications.topologySpreadConstraints | list | `[]` (defaults to global.topologySpreadConstraints) | Assign custom [TopologySpreadConstraints] rules to the application controller |
| notifications.triggers | object | `{}` | The trigger defines the condition when the notification should be sent |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)

[Argo CD RBAC policy]: https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/
[affinity]: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
[BackendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/concepts/backendconfig#backendconfigspec_v1beta1_cloudgooglecom
[CSS styles]: https://argo-cd.readthedocs.io/en/stable/operator-manual/custom-styles/
[changelog]: https://artifacthub.io/packages/helm/argo/argo-cd?modal=changelog
[DNS configuration]: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
[external cluster credentials]: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters
[FrontendConfigSpec]: https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features#configuring_ingress_features_through_frontendconfig_parameters
[declarative setup]: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup
[gRPC-ingress]: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/
[GnuPG]: https://argo-cd.readthedocs.io/en/stable/user-guide/gpg-verification/
[HPA]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
[MetricRelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs
[Node selector]: https://kubernetes.io/docs/user-guide/node-selection/
[PodDisruptionBudget]: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[RelabelConfigs]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[TopologySpreadConstraints]: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
[values.yaml]: values.yaml
[v2.2 to 2.3 upgrade instructions]: https://github.com/argoproj/argo-cd/blob/v2.3.0/docs/operator-manual/upgrading/2.2-2.3.md
[tini]: https://github.com/argoproj/argo-cd/pull/12707
[EKS EoL]: https://endoflife.date/amazon-eks
[Kubernetes Compatibility Matrix]: https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#supported-versions
[Applications in any namespace]: https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/#applications-in-any-namespace
