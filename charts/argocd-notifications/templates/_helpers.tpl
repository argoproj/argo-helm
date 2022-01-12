{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "argocd-notifications.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argocd-notifications.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argocd-notifications.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "argocd-notifications.labels" -}}
helm.sh/chart: {{ include "argocd-notifications.chart" . }}
{{ include "argocd-notifications.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common metrics labels
*/}}
{{- define "argocd-notifications.metrics.labels" -}}
helm.sh/chart: {{ include "argocd-notifications.chart" . }}
{{ include "argocd-notifications.metrics.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Common slack bot labels
*/}}
{{- define "argocd-notifications.bots.slack.labels" -}}
helm.sh/chart: {{ include "argocd-notifications.chart" . }}
{{ include "argocd-notifications.bots.slack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "argocd-notifications.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-notifications.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector metrics labels
*/}}
{{- define "argocd-notifications.metrics.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-notifications.name" . }}-metrics
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector slack bot labels
*/}}
{{- define "argocd-notifications.bots.slack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argocd-notifications.name" . }}-bot
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "argocd-notifications.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "argocd-notifications.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the bot service account to use
*/}}
{{- define "argocd-notifications.bots.slack.serviceAccountName" -}}
{{- if .Values.bots.slack.serviceAccount.create -}}
    {{ default (printf "%s-bot" (include "argocd-notifications.fullname" .)) .Values.bots.slack.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.bots.slack.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the secret to use
*/}}
{{- define "argocd-notifications.secretName" -}}
{{- if .Values.secret.create -}}
    {{ default (printf "%s-secret" (include "argocd-notifications.fullname" .)) .Values.secret.name }}
{{- else -}}
    {{ default "argocd-notifications-secret" .Values.secret.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the configmap to use
*/}}
{{- define "argocd-notifications.configMapName" -}}
{{- if .Values.cm.create -}}
    {{ default (printf "%s-cm" (include "argocd-notifications.fullname" .)) .Values.cm.name }}
{{- else -}}
    {{ default "argocd-notifications-cm" .Values.cm.name }}
{{- end -}}
{{- end -}}
