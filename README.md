# Argo Helm Charts

Repository contains helm charts for http://argoproj.io/ projects. Helm charts repository is hosted using Github pages 
and can be added using following command:

```
helm repo add argo https://argoproj.github.io/argo-helm
```

## Publishing changes

To push changes use following script:

```
GIT_PUSH=true ./scripts/publish.sh
```

Script generates tar file for each chart in `charts` directory and push changes to `gh-pages` branch.
Write access to https://github.com/argoproj/argo-helm.git is required to publish changes.
