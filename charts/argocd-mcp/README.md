# argocd-mcp

A Helm chart for the Argo CD MCP Server

## Installation

Install the chart from the OCI registry:

```console
helm install argocd-mcp oci://ghcr.io/argoproj/argo-helm/argocd-mcp --namespace <desired installation namespace>
```

Alternatively, add the Argo Helm repository and install the chart:

```console
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd-mcp argo/argocd-mcp --namespace <desired installation namespace>
```

## Configuration

### Argo CD connection

Configure the Argo CD server address with `argocd.baseUrl`.

The Argo CD API token must be provided through an existing Kubernetes Secret. Plaintext API tokens are not accepted through chart values.

For example, create a Secret:

```console
kubectl create secret generic argocd-mcp-argocd \
  --from-literal=token='<argocd-api-token>'
```

Then configure the chart:

```yaml
argocd:
  baseUrl: https://argocd.example.com
  apiToken:
    existingSecret: argocd-mcp-argocd
    key: token
```

The Argo CD API token authenticates the MCP server to Argo CD. It does not authenticate clients connecting to the MCP server.

### Exposing the MCP server

The Kubernetes Service is disabled by default. When the Service is enabled, the MCP server binds to `0.0.0.0` and inbound authentication must be configured.

Create a Secret containing the inbound MCP authentication token:

```console
kubectl create secret generic argocd-mcp-auth \
  --from-literal=token='<mcp-auth-token>'
```

Then enable the Service and reference the Secret:

```yaml
service:
  enabled: true

mcp:
  authToken:
    existingSecret: argocd-mcp-auth
    key: token
```

Clients must send this token using the `Authorization: Bearer <token>` header.

If an external proxy or service mesh already authenticates callers, unauthenticated access to the MCP listener can be explicitly enabled:

```yaml
service:
  enabled: true

mcp:
  allowUnauthenticated: true
```

Only enable this when authentication is enforced by another component.

### Transport

The chart supports the network transports exposed by the MCP server:

```yaml
mcp:
  transport: http
  port: 3000
```

Supported transport values are `http` and `sse`.

### Read-only mode

Read-only mode disables MCP tools that modify Argo CD resources:

```yaml
mcp:
  readOnly: true
```

### Stateless mode

The HTTP transport normally maintains client sessions in memory. For deployments where requests may be routed across multiple replicas without session affinity, enable stateless mode:

```yaml
mcp:
  stateless: true
```

### Ingress

Ingress requires the Kubernetes Service to be enabled.

For example:

```yaml
service:
  enabled: true

mcp:
  authToken:
    existingSecret: argocd-mcp-auth
    key: token

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: mcp.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity settings for pod assignment |
| argocd.apiToken.existingSecret | string | `""` | Name of an existing Secret containing the Argo CD API token |
| argocd.apiToken.key | string | `"token"` | Key in the existing Secret containing the Argo CD API token |
| argocd.baseUrl | string | `""` | Default Argo CD base URL used by the MCP server |
| extraArgs | list | `[]` | Extra arguments to pass to the MCP server container |
| extraEnv | list | `[]` | Extra environment variables for the MCP server container |
| extraEnvFrom | list | `[]` | Extra envFrom to pass to the MCP server container |
| extraObjects | list | `[]` | Extra Kubernetes manifests to deploy with the chart |
| extraVolumeMounts | list | `[]` | Extra volume mounts to add to the container |
| extraVolumes | list | `[]` | Extra volumes to add to the pod |
| fullnameOverride | string | `""` | Global fullname override |
| image.pullPolicy | string | `"IfNotPresent"` | Default image pull policy |
| image.repository | string | `"quay.io/argoprojlabs/mcp-for-argocd"` | Default image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets for the deployment |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable an Ingress for the MCP server |
| ingress.hosts | list | `[{"host":"argocd-mcp.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts configuration |
| ingress.labels | object | `{}` | Additional labels for the Ingress |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| mcp.allowUnauthenticated | bool | `false` | Allow non-loopback HTTP access without MCP_AUTH_TOKEN. Use only when an external proxy or service mesh authenticates callers. |
| mcp.allowedHosts | list | `[]` | Additional Host headers accepted by the MCP HTTP server |
| mcp.allowedOrigins | list | `[]` | Additional browser origins accepted by the MCP HTTP server |
| mcp.authToken.existingSecret | string | `""` | Name of an existing Secret containing the inbound MCP authentication token |
| mcp.authToken.key | string | `"token"` | Key in the existing Secret containing the inbound MCP authentication token |
| mcp.port | int | `3000` | Port exposed by the MCP HTTP server |
| mcp.readOnly | bool | `false` | Run the MCP server in read-only mode |
| mcp.stateless | bool | `false` | Run the HTTP transport without session affinity requirements |
| mcp.transport | string | `"http"` | Transport protocol used by the MCP server |
| nameOverride | string | `""` | Global name override |
| namespaceOverride | string | `""` | Global namespace override |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to be added to pods |
| podLabels | object | `{}` | Labels to be added to pods |
| podSecurityContext | object | `{"runAsNonRoot":true}` | Pod security context settings |
| replicaCount | int | `1` | Number of desired pods |
| resources | object | `{}` | Resource limits and requests for the container |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | Container security context settings |
| service.annotations | object | `{}` | Annotations to add to the Service |
| service.enabled | bool | `false` | Enable a Service for the MCP server |
| service.labels | object | `{}` | Labels to add to the Service |
| service.port | int | `3000` | Kubernetes port where service is exposed |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.labels | object | `{}` | Labels to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)