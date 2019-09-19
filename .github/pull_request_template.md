* [ ] I have update the chart version in `Chart.yaml` following Semantic Versioning.
* [ ] All new values are backwards compatible and/or have sensible default.
* [ ] I have installed the chart myself and it works.

E.g. for Argo Workflows:

```
helm install charts/argo
argo version
```

E.g. for Argo CD:

```
helm install charts/argo-cd --namespace argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
argocd version
```
