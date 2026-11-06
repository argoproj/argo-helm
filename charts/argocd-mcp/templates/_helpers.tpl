{{/*
Expand the name of the chart.
*/}}
{{- define "argocd-mcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "argocd-mcp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version used by the chart label.
*/}}
{{- define "argocd-mcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "argocd-mcp.labels" -}}
helm.sh/chart: {{ include "argocd-mcp.chart" . }}
{{ include "argocd-mcp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "argocd-mcp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-mcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "argocd-mcp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argocd-mcp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "argocd-mcp.namespace" -}}
  {{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Validate network exposure configuration.
*/}}
{{- define "argocd-mcp.validateNetworkExposure" -}}
{{- if and .Values.service.enabled (not .Values.mcp.authToken.existingSecret) (not .Values.mcp.allowUnauthenticated) }}
{{- fail "mcp.authToken.existingSecret must be set when service.enabled=true, or mcp.allowUnauthenticated must be explicitly set to true when authentication is provided by an external proxy or service mesh" }}
{{- end }}
{{- end }}

{{/*
Validate ingress configuration.
*/}}
{{- define "argocd-mcp.validateIngress" -}}
{{- if and .Values.ingress.enabled (not .Values.service.enabled) }}
{{- fail "service.enabled must be true when ingress.enabled=true" }}
{{- end }}
{{- end }}


{{/*
Validate MCP transport.
*/}}
{{- define "argocd-mcp.validateTransport" -}}
{{- if not (has .Values.mcp.transport (list "http" "sse")) }}
{{- fail "mcp.transport must be one of: http, sse" }}
{{- end }}
{{- end }}
