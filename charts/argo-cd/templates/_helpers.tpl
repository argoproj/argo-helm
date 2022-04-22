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
Return the appropriate apiVersion for ingress
*/}}
{{- define "argo-cd.ingress.apiVersion" -}}
{{- if .Values.apiVersionOverrides.ingress -}}
{{- print .Values.apiVersionOverrides.ingress -}}
{{- else if semverCompare "<1.14-0" (include "argo-cd.kubeVersion" $) -}}
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

{{/*
Return the default Argo CD app version
*/}}
{{- define "argo-cd.defaultTag" -}}
  {{- default .Chart.AppVersion .Values.global.image.tag }}
{{- end -}}

{{/*
Create the name of the notifications controller secret to use
*/}}
{{- define "argo-cd.notifications.secretName" -}}
{{- if .Values.notifications.secret.create -}}
    {{ default (printf "%s-secret" (include "argo-cd.notifications.fullname" .)) .Values.notifications.secret.name }}
{{- else -}}
    {{ default "argocd-notifications-secret" .Values.notifications.secret.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the configmap to use
*/}}
{{- define "argo-cd.notifications.configMapName" -}}
{{- if .Values.notifications.cm.create -}}
    {{ default (printf "%s-cm" (include "argo-cd.notifications.fullname" .)) .Values.notifications.cm.name }}
{{- else -}}
    {{ default "argocd-notifications-cm" .Values.notifications.cm.name }}
{{- end -}}
{{- end -}}

{{- define "argo-cd.redisPasswordEnv" -}}
  {{- if or .Values.externalRedis.password .Values.externalRedis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.externalRedis.existingSecret }}
      name: {{ .Values.externalRedis.existingSecret }}
    {{- else }}
      name: {{ template "argo-cd.redis.fullname" . }}
    {{- end }}
      key: redis-password
  {{- end }}
{{- end -}}
