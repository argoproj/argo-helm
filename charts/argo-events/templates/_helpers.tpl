{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "argo-events.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-events.fullname" -}}
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
Create controller name and version as used by the chart label.
*/}}
{{- define "argo-events.controller.fullname" -}}
{{- printf "%s-%s" (include "argo-events.fullname" .) .Values.controller.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "argo-events.controller.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (include "argo-events.controller.fullname" .) .Values.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create webhook name and version as used by the chart label.
*/}}
{{- define "argo-events.webhook.fullname" }}
{{- printf "%s-%s" (include "argo-events.fullname" .) .Values.webhook.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the webhook service account to use
*/}}
{{- define "argo-events.webhook.serviceAccountName" -}}
{{- if .Values.webhook.serviceAccount.create -}}
    {{ default (include "argo-events.webhook.fullname" .) .Values.webhook.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.webhook.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argo-events.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create kubernetes friendly chart version label for the controller.

Examples:
image.tag = v1.7.3
output    = v1.7.3

image.tag = v1.7.3@sha256:a40f4f3ea20d354f00ab469a9f73102668fa545c4d632e1a8e11a206ad3093f3
output    = v1.7.3
*/}}
{{- define "argo-events.controller_chart_version_label" -}}
{{- regexReplaceAll "[^a-zA-Z0-9-_.]+" (regexReplaceAll "@sha256:[a-f0-9]+" (default (include "argo-events.defaultTag" .) .Values.controller.image.tag) "") "" | trunc 63 | quote -}}
{{- end -}}

{{/*
Create kubernetes friendly chart version label for the events webhook.

Examples:
image.tag = v1.7.3
output    = v1.7.3

image.tag = v1.7.3@sha256:a40f4f3ea20d354f00ab469a9f73102668fa545c4d632e1a8e11a206ad3093f3
output    = v1.7.3
*/}}
{{- define "argo-events.webhook_chart_version_label" -}}
{{- regexReplaceAll "[^a-zA-Z0-9-_.]+" (regexReplaceAll "@sha256:[a-f0-9]+" (default (include "argo-events.defaultTag" .) .Values.webhook.image.tag) "") "" | trunc 63 | quote -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "argo-events.labels" -}}
helm.sh/chart: {{ include "argo-events.chart" .context }}
{{ include "argo-events.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: argo-events
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-events.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "argo-events.name" .context }}-{{ .name }}
{{- end }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Return the default Argo Events app version
*/}}
{{- define "argo-events.defaultTag" -}}
  {{- default .Chart.AppVersion .Values.global.image.tag }}
{{- end -}}

{{/*
Define Pdb apiVersion
*/}}
{{- define "argo-events.pdb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" }}
{{- printf "policy/v1" -}}
{{- else }}
{{- printf "policy/v1beta1" -}}
{{- end }}
{{- end }}
