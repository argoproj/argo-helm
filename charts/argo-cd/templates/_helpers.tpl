{{/* vim: set filetype=mustache: */}}
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
Create Dex server endpoint
*/}}
{{- define "argo-cd.dex.server" -}}
{{- $insecure := index .Values.configs.params "dexserver.disable.tls" | toString -}}
{{- $scheme := (eq $insecure "true") | ternary "http" "https" -}}
{{- $host := include "argo-cd.dex.fullname" . -}}
{{- $port := int .Values.dex.servicePortHttp -}}
{{- printf "%s://%s:%d" $scheme $host $port }}
{{- end }}

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
Argo Configuration Preset Values (Incluenced by Values configuration)
*/}}
{{- define "argo-cd.config.cm.presets" -}}
{{- if .Values.configs.styles -}}
ui.cssurl: "./custom/custom.styles.css"
{{- end -}}
{{- if not .Values.global.cluster.ngcp}}
resource.inclusions: |
  - apiGroups:
    - "kubeflow.org"
    kinds:
    - MPIJob
    - TFJob
    - MXJob
    - PyTorchJob
    - XGBoostJob
    clusters:
    - https://10.135.192.1:443
    - https://kubernetes.default.svc
    - apiGroups:
    - "networking.k8s.io"
    kinds:
    - Ingress
    - NetworkPolicy
    clusters:
    - https://10.135.192.1:443
    - https://kubernetes.default.svc
    - apiGroups:
    - "cert-manager.io"
    kinds:
    - Certificate
    clusters:
    - https://10.135.192.1:443
    - https://kubernetes.default.svc
    - apiGroups:
    - "*"
    kinds:
    - Deployment
    - Pod
    - ConfigMap
    - Event
    - LimitRange
    - PersistentVolumeClaim
    - PodTemplate
    - ReplicationController
    - Service
    - Secret
    - Endpoint
    - ControllerRevision
    - Application
    - PodDisruptionBudget
    - ServiceAccount
    - StatefulSet
    - SealedSecret
    - Workflow
    - WorkflowTemplate
    - CronWorkflow
    - AppProject
    - Role
    - RoleBinding
    - InferenceService
    - Revision
    - PodAutoscaler
    - Virtualservice
    - HorizontalPodAutoscaler
    - Batch
    - Extention
    - Job
    - CronJob
    - ResourceQuota
    - IngressRoute
    - IngressRouteTcp
    - IngressRouteUdp
    - Middleware
    - TlsOption
    - TlsStore
    - TraefikService
    - DataVolume
    - ScaledObject
    - Issuer
    - CertificateRequest
    - ServiceMonitor
    - VirtualServer
    clusters:
    - https://10.135.192.1:443
    - https://kubernetes.default.svc
{{- end}}
{{- end -}}

{{/*
Merge Argo Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config.cm" -}}
{{- $config := (mergeOverwrite (deepCopy (omit .Values.configs.cm "create" "annotations")) (.Values.server.config | default dict))  -}}
{{- $preset := include "argo-cd.config.cm.presets" . | fromYaml | default dict -}}
{{- range $key, $value := mergeOverwrite $preset $config }}
{{ $key }}: {{ toString $value | toYaml }}
{{- end }}
{{- end -}}

{{/*
Argo Params Default Configuration Presets
*/}}
{{- define "argo-cd.config.params.presets" -}}
repo.server: "{{ include "argo-cd.repoServer.fullname" . }}:{{ .Values.repoServer.service.port }}"
server.repo.server.strict.tls: {{ .Values.repoServer.certificateSecret.enabled | toString }}
{{- with include "argo-cd.redis.server" . }}
redis.server: {{ . | quote }}
{{- end }}
{{- if .Values.dex.enabled }}
server.dex.server: {{ include "argo-cd.dex.server" . | quote }}
server.dex.server.strict.tls: {{ .Values.dex.certificateSecret.enabled | toString }}
{{- end }}
{{- range $component := tuple "applicationsetcontroller" "controller" "server" "reposerver" }}
{{ $component }}.log.format: {{ $.Values.global.logging.format | quote }}
{{ $component }}.log.level: {{ $.Values.global.logging.level | quote }}
{{- end }}
{{- if .Values.applicationSet.enabled }}
applicationsetcontroller.enable.leader.election: {{ gt (.Values.applicationSet.replicaCount | int64) 1 }}
{{- end }}
{{- end -}}

{{/*
Merge Argo Params Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config.params" -}}
{{- $config := omit .Values.configs.params "annotations" }}
{{- $preset := include "argo-cd.config.params.presets" . | fromYaml | default dict -}}
{{- range $key, $value := mergeOverwrite $preset $config }}
{{ $key }}: {{ toString $value | toYaml }}
{{- end }}
{{- end -}}

{{- define "coreweave.vpc"}}
  {{- if gt (len .Values.global.network.vpcs) 0}}
vpc.coreweave.cloud/name: "{{ include "vpcList" . }}"
  {{- end}}
vpc.coreweave.cloud/kubernetes-networking: "{{- not .Values.global.network.disableK8sNetworking}}"
{{- end}}

{{/*
Convert VPC array to comma separated list
*/}}
{{- define "vpcList" -}}
{{- $names := list -}}
{{- range .Values.global.network.vpcs }}
{{- $names = .name | append $names -}}
{{- end -}}
{{- join ","  $names }}
{{- end -}}

# Taken from bitnami common, allows for adding template strings to values file 
{{- define "argo-cd.retemplate"}}
  {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end}}