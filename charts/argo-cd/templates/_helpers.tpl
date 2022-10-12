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
Truncated at 52 chars because StatefulSet label 'controller-revision-hash' is limited
to 63 chars and it includes 10 chars of hash and a separating '-'.
*/}}
{{- define "argo-cd.controller.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.controller.name | trunc 52 | trimSuffix "-" -}}
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
{{- $redisHa := (index .Values "redis-ha") -}}
{{- $redisHaContext := dict "Chart" (dict "Name" "redis-ha") "Release" .Release "Values" $redisHa -}}
{{- if $redisHa.enabled -}}
    {{- if $redisHa.haproxy.enabled -}}
        {{- printf "%s-haproxy" (include "redis-ha.fullname" $redisHaContext) | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- else -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.redis.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return Redis server endpoint
*/}}
{{- define "argo-cd.redis.server" -}}
{{- $redisHa := (index .Values "redis-ha") -}}
{{- if or (and .Values.redis.enabled (not $redisHa.enabled)) (and $redisHa.enabled $redisHa.haproxy.enabled) }}
    {{- printf "%s:%s" (include "argo-cd.redis.fullname" .)  (toString .Values.redis.servicePort) }}
{{- else if and .Values.externalRedis.host .Values.externalRedis.port }}
    {{- printf "%s:%s" .Values.externalRedis.host (toString .Values.externalRedis.port) }}
{{- end }}
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
Create argocd application set name and version as used by the chart label.
*/}}
{{- define "argo-cd.applicationSet.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.applicationSet.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create argocd notifications name and version as used by the chart label.
*/}}
{{- define "argo-cd.notifications.fullname" -}}
{{- printf "%s-%s" (include "argo-cd.fullname" .) .Values.notifications.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "argo-cd.controllerServiceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (include "argo-cd.controller.fullname" .) .Values.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the dex service account to use
*/}}
{{- define "argo-cd.dexServiceAccountName" -}}
{{- if .Values.dex.serviceAccount.create -}}
    {{ default (include "argo-cd.dex.fullname" .) .Values.dex.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.dex.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the redis service account to use
*/}}
{{- define "argo-cd.redisServiceAccountName" -}}
{{- if .Values.redis.serviceAccount.create -}}
    {{ default (include "argo-cd.redis.fullname" .) .Values.redis.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.redis.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the Argo CD server service account to use
*/}}
{{- define "argo-cd.serverServiceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (include "argo-cd.server.fullname" .) .Values.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the repo-server service account to use
*/}}
{{- define "argo-cd.repoServerServiceAccountName" -}}
{{- if .Values.repoServer.serviceAccount.create -}}
    {{ default (include "argo-cd.repoServer.fullname" .) .Values.repoServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.repoServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the application set service account to use
*/}}
{{- define "argo-cd.applicationSetServiceAccountName" -}}
{{- if .Values.applicationSet.serviceAccount.create -}}
    {{ default (include "argo-cd.applicationSet.fullname" .) .Values.applicationSet.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.applicationSet.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the notifications service account to use
*/}}
{{- define "argo-cd.notificationsServiceAccountName" -}}
{{- if .Values.notifications.serviceAccount.create -}}
    {{ default (include "argo-cd.notifications.fullname" .) .Values.notifications.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.notifications.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the notifications bots slack service account to use
*/}}
{{- define "argo-cd.notificationsBotsSlackServiceAccountName" -}}
{{- if .Values.notifications.bots.slack.serviceAccount.create -}}
    {{ default (include "argo-cd.notifications.fullname" .) .Values.notifications.bots.slack.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.notifications.bots.slack.serviceAccount.name }}
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
{{- with .context.Values.global.additionalLabels }}
{{ toYaml . }}
{{- end }}
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

{{/*
Argo Params Default Configuration Presets
*/}}
{{- define "argo-cd.config.params.presets" -}}
repo.server: "{{ include "argo-cd.repoServer.fullname" . }}:{{ .Values.repoServer.service.port }}"
{{- with include "argo-cd.redis.server" . }}
redis.server: {{ . | quote }}
{{- end }}
{{- if .Values.dex.enabled }}
server.dex.server: "http://{{ include "argo-cd.dex.fullname" . }}:{{ .Values.dex.servicePortHttp }}"
{{- end }}
{{- range $component := tuple "controller" "server" "reposerver" }}
{{ $component }}.log.format: {{ $.Values.global.logging.format | quote }}
{{ $component }}.log.level: {{ $.Values.global.logging.level | quote }}
{{- end }}
{{- end -}}

{{/*
Merge Argo Params Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config.params" -}}
{{- $config := omit .Values.configs.params "annotations" }}
{{- $preset := include "argo-cd.config.params.presets" $ | fromYaml | default dict -}}
{{- range $key, $value := mergeOverwrite $preset $config }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{/*
Return the default Argo CD app version
*/}}
{{- define "argo-cd.defaultTag" -}}
  {{- default .Chart.AppVersion .Values.global.image.tag }}
{{- end -}}
