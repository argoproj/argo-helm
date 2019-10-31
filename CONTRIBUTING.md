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
kubectl delete crd -l app.kubernetes.io/part-of=argo-cd
```

Minimally:

```
helm install charts/argo-cd --namespace argocd -n argo-cd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

In a new terminal:

```
argocd version
# reset password to 'Password1!'
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$hDj12Tw9xVmvybSahN1Y0.f9DZixxN8oybyA32Uy/eqWklFU4Mo8O",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
argocd login localhost:8080 --username admin --password 'Password1!'
```

Create and sync app:

```
argocd app create guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --path guestbook --project default --repo https://github.com/argoproj/argocd-example-apps.git
argocd app sync guestbook
```

## Publishing Changes

Changes are automatically publish whenever a commit is merged to master. The CI job (see `.circleci/config.yaml`) runs this:

```
GIT_PUSH=true ./scripts/publish.sh
```

Script generates tar file for each chart in `charts` directory and push changes to `gh-pages` branch.
Write access to https://github.com/argoproj/argo-helm.git is required to publish changes.
