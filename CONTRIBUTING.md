# Contributing

Argo Helm is a collection of **community maintained** charts. Therefore we rely on you to test your changes correctly


## Publishing Changes

To push changes use following script:

```
GIT_PUSH=true ./scripts/publish.sh
```

Script generates tar file for each chart in `charts` directory and push changes to `gh-pages` branch.
Write access to https://github.com/argoproj/argo-helm.git is required to publish changes.
