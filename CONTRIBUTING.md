# Contributing

Argo Helm is a collection of **community maintained** charts. Therefore we rely on you to test your changes sufficiently.


# Pull Requests

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests. See the above stated requirements for PR on this project.

## Versioning

Each chart's version follows the [semver standard](https://semver.org/). New charts should start at version `1.0.0`, if it's considered stable. If it's not considered stable, it must be released as [prerelease](#prerelease).

Any breaking changes to a chart (backwards incompatible) require:

  * Bump of the current Major version of the chart
  * State possible manual changes for this chart version in the `Upgrading` section of the chart's `README.md.gotmpl` ([See Upgrade](#upgrades))

### Immutability

Each release for each chart must be immutable. Any change to a chart (even just documentation) requires a version bump. Trying to release the same version twice will result in an error.


### Artifact Hub Annotations

Since we release our charts on Artifact Hub we encourage making use of the provided chart annotations for Artifact Hub.

  * [https://artifacthub.io/docs/topics/annotations/helm/](https://artifacthub.io/docs/topics/annotations/helm/)

#### Changelog

We want to deliver transparent chart releases for our chart consumers. Therefore we require a changelog per new chart release.

Changes on a chart must be documented in a chart specific changelog in the `Chart.yaml` [Annotation Section](https://helm.sh/docs/topics/charts/#the-chartyaml-file). For every new release the entire `artifacthub.io/changes` needs to be rewritten. Each change requires a new bullet point following the pattern `- "[{type}]: {description}"`. You can use the following template:

```
name: argo-cd
version: 3.4.1
...
annotations:
  artifacthub.io/changes: |
    - "[Added]: Something New was added"
    - "[Changed]: Changed Something within this chart"
    - "[Changed]: Changed Something else within this chart"
    - "[Deprecated]: Something deprecated"
    - "[Removed]: Something was removed"
    - "[Fixed]: Something was fixed"
    - "[Security]": Some Security Patch was included"
```

# Testing

## Testing Argo Workflows Changes

Minimally:

```
helm install charts/argo -n argo
argo version
```

Follow this instructions for running a hello world workflow.

## Testing Argo CD Changes

Clean-up:

```
helm delete argo-cd --purge
kubectl delete crd -l app.kubernetes.io/part-of=argocd
```

Pre-requisites:
```
helm repo add redis-ha https://dandydeveloper.github.io/charts/
helm dependency update
```

Minimally:

```
helm install charts/argo-cd --namespace argocd -n argo-cd
kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443
```

In a new terminal:

```
argocd version --server localhost:8080 --insecure
# reset password to 'Password1!'
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$hDj12Tw9xVmvybSahN1Y0.f9DZixxN8oybyA32Uy/eqWklFU4Mo8O",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
argocd login localhost:8080 --username admin --password 'Password1!'

# WARNING: server certificate had error: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
```

Create and sync app:

```
argocd app create guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --path guestbook --project default --repo https://github.com/argoproj/argocd-example-apps.git
argocd app sync guestbook
```

## Testing Argo CD Notification Changes

Thorough testing of argocd-notifications would require one or more notification services (Slack, OpsGenie, etc), however
minimal testing mostly consists of successful Helm chart installation and the argocd-notifications controller having
access to the `Application` resources in the same namespace that Argo CD is installed.

```
helm install argocd-notifications charts/argocd-notifications --namespace argocd
```

## New Application Versions

When raising application versions ensure you make the following changes:

- `values.yaml`: Bump all instances of the container image version
- `Chart.yaml`: Ensure `appVersion` matches the above container image and bump `version`

Please ensure chart version changes adhere to semantic versioning standards:

- Patch: App version patch updates, backwards compatible optional chart features
- Minor: New chart functionality (sidecars), major application updates or minor non-backwards compatible changes
- Major: Large chart rewrites, major non-backwards compatible or destructive changes

## Testing Charts

As part of the Continuous Integration system we run Helm's [Chart Testing](https://github.com/helm/chart-testing) tool.

The checks for this tool are stricter than the standard Helm requirements, where fields normally considered optional like `maintainer` are required in the standard spec and must be valid GitHub usernames.

Linting configuration can be found in [ct-lint.yaml](./.github/configs/ct-lint.yaml)

The linting can be invoked manually with the following command:

```
./scripts/lint.sh
```

## Publishing Changes

Changes are automatically publish whenever a commit is merged to master. The CI job (see `./.github/workflows/publish.yml`).
