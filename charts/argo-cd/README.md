# Argo CD Chart

A Helm chart for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes. CoreWeave provides default configurations for Ingress, Node Selection, Affinity, and more to provide a simple setup process. Using this chart you can customize more parameters about the applications, RBAC for users of argo-cd, metrics, and much more.

## Using Custom Ingress

To use a custom Ingress hostname with your Argo-CD Deployment, you will need to specify a custom externalHostName, as well as the ingress controller class name to be used for Ingress. Because of the limitations of CoreWeave's Ingress controller you will need to deploy your own in order to use a custom Hostname.
## Additional Information

This is a **community maintained** chart. This chart installs [argo-cd](https://argoproj.github.io/argo-cd/), a declarative, GitOps continuous delivery tool for Kubernetes.

The default installation is intended to be similar to the provided Argo CD [releases](https://github.com/argoproj/argo-cd/releases).

If you want to avoid including sensitive information unencrypted (clear text) in your version control, make use of the [declarative set up](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) of Argo CD.
For instance, rather than adding repositories and their keys in your Helm values, you could deploy [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) with contents as seen in this [repositories section](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories) or any other secrets manager service (i.e. HashiCorp Vault, AWS/GCP Secrets Manager, etc.).
