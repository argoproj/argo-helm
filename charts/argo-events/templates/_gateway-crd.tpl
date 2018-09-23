{{- define "gateway-crd-json" }}
{
  "apiVersion": "apiextensions.k8s.io/{{ .Values.crd.version }}",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "name": "gateways.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "Gateway",
      "listKind": "GatewayList",
      "plural": "gateways",
      "singular": "gateway"
    },
    "scope": "Namespaced",
    "version": "v1alpha1"
  }
}
{{- end}}
