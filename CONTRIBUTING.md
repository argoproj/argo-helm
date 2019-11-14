# Contributing

Argo Helm is a collection of **community maintained** charts. Therefore we rely on you to test your changes sufficiently.

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

## New Application Versions

When raising application versions ensure you make the following changes:

- `values.yaml`: Bump all instances of the container image version
- `Chart.yaml`: Ensure `appVersion` matches the above container image and bump `version`

Please ensure chart version changes adhere to semantic versioning standards:

- Patch: App version patch updates, backwards compatible optional chart features
- Minor: New chart functionality (sidecars), major application updates or minor non-backwards compatible changes
- Major: Large chart rewrites, major non-backwards compatible or destructive changes

## Testing Charts

As part of the Continous Intergration system we run Helm's [Chart Testing](https://github.com/helm/chart-testing) tool.

The checks for this tool are stricter than the standard Helm requirements, where fields normally considered optional like `maintainer` are required in the standard spec and must be valid GitHub usernames.

Linting configuration can be found in [lintconf.yaml](.circleci/lintconf.yaml)

The linting can be invoked manually with the following command:

```
./scripts/lint.sh
```

## Publishing Changes

Changes are automatically publish whenever a commit is merged to master. The CI job (see `.circleci/config.yaml`) runs this:

```
GIT_PUSH=true ./scripts/publish.sh
```

Script generates tar file for each chart in `charts` directory and push changes to `gh-pages` branch.
Write access to https://github.com/argoproj/argo-helm.git is required to publish changes.
