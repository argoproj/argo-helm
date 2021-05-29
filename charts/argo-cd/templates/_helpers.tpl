{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "argo-cd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-cd.fullname" -}}
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
Create controller name and version as used by the chart label.
*/}}
{{- define "argo-cd.controller.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.controller.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create dex name and version as used by the chart label.
*/}}
{{- define "argo-cd.dex.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.dex.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create redis name and version as used by the chart label.
*/}}
{{- define "argo-cd.redis.fullname" -}}
{{ $redisHa := (index .Values "redis-ha") }}
{{- if $redisHa.enabled -}}
    {{- if $redisHa.haproxy.enabled -}}
        {{- printf "%s-redis-ha-haproxy" .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- else -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.redis.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create argocd server name and version as used by the chart label.
*/}}
{{- define "argo-cd.server.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create argocd repo-server name and version as used by the chart label.
*/}}
{{- define "argo-cd.repoServer.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.repoServer.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "argo-cd.controllerServiceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (include "argo-cd.fullname" .) .Values.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the dex service account to use
*/}}
{{- define "argo-cd.dexServiceAccountName" -}}
{{- if .Values.dex.serviceAccount.create -}}
    {{ default (include "argo-cd.fullname" .) .Values.dex.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.dex.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the ArgoCD server service account to use
*/}}
{{- define "argo-cd.serverServiceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (include "argo-cd.fullname" .) .Values.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the repo-server service account to use
*/}}
{{- define "argo-cd.repoServerServiceAccountName" -}}
{{- if .Values.repoServer.serviceAccount.create -}}
    {{ default (include "argo-cd.fullname" .) .Values.repoServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.repoServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argo-cd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "argo-cd.labels" -}}
helm.sh/chart: {{ include "argo-cd.chart" .context }}
{{ include "argo-cd.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: argocd
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-cd.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "argo-cd.name" .context }}-{{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress
*/}}
{{- define "argo-cd.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "argo-cd.kubeVersion" $) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "argo-cd.kubeVersion" $) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "argo-cd.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride }}
{{- end -}}

{{/* 
Argo Configuration Preset Values (Incluenced by Values configuration)
*/}}
{{- define "argo-cd.config.presets" -}}
  {{- if .Values.configs.styles }}
ui.cssurl: "./custom/custom.styles.css"
  {{- end }}
{{- end -}}

{{/* 
Merge Argo Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config" -}}
  {{- if .Values.server.configEnabled -}}
{{- toYaml (mergeOverwrite (default dict (fromYaml (include "argo-cd.config.presets" $))) .Values.server.config) }}
  {{- end -}}
{{- end -}}