{{/* vim: set filetype=mustache: */}}
{{/*
Create a component fullname while preserving the component suffix.
*/}}
{{- define "argo-cd.component.fullname" -}}
{{- $ctx := .context -}}
{{- $name := .name -}}
{{- $suffix := .suffix | default "" -}}
{{- $maxLen := .maxLen | default 63 | int -}}
{{- $componentName := $name -}}
{{- if $suffix -}}
{{- $componentName = printf "%s-%s" $name $suffix -}}
{{- end -}}
{{- /* Reserve space for hyphen + componentName */ -}}
{{- $baseMaxLen := sub $maxLen (add (len $componentName) 1) | int -}}
{{- if lt $baseMaxLen 1 -}}
{{- fail (printf "cannot build fullname for component %q: maxLen %d leaves no room for base name" $componentName $maxLen) -}}
{{- end -}}
{{- $base := include "argo-cd.fullname" $ctx | trunc $baseMaxLen | trimSuffix "-" -}}
{{- printf "%s-%s" $base $componentName | trunc $maxLen | trimSuffix "-" -}}
{{- end -}}

{{/*
Create controller name and version as used by the chart label.
Truncated at 52 chars because StatefulSet label 'controller-revision-hash' is limited
to 63 chars and it includes 10 chars of hash and a separating '-'.
*/}}
{{- define "argo-cd.controller.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.controller.name "maxLen" 52) -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "argo-cd.controller.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (include "argo-cd.controller.fullname" .) .Values.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create dex name and version as used by the chart label.
*/}}
{{- define "argo-cd.dex.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.dex.name) -}}
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
Create the name of the dex service account to use
*/}}
{{- define "argo-cd.dex.serviceAccountName" -}}
{{- if .Values.dex.serviceAccount.create -}}
    {{ default (include "argo-cd.dex.fullname" .) .Values.dex.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.dex.serviceAccount.name }}
{{- end -}}
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
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.redis.name) -}}
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
Create the name of the redis service account to use
*/}}
{{- define "argo-cd.redis.serviceAccountName" -}}
{{- if .Values.redis.serviceAccount.create -}}
    {{ default (include "argo-cd.redis.fullname" .) .Values.redis.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.redis.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create Redis secret-init name
*/}}
{{- define "argo-cd.redisSecretInit.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.redisSecretInit.name) -}}
{{- end -}}

{{/*
Create the name of the Redis secret-init service account to use
*/}}
{{- define "argo-cd.redisSecretInit.serviceAccountName" -}}
{{- if .Values.redisSecretInit.serviceAccount.create -}}
    {{ default (include "argo-cd.redisSecretInit.fullname" .) .Values.redisSecretInit.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.redisSecretInit.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create argocd server name and version as used by the chart label.
*/}}
{{- define "argo-cd.server.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.server.name) -}}
{{- end -}}

{{/*
Create the name of the Argo CD server service account to use
*/}}
{{- define "argo-cd.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (include "argo-cd.server.fullname" .) .Values.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create argocd repo-server name and version as used by the chart label.
*/}}
{{- define "argo-cd.repoServer.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.repoServer.name) -}}
{{- end -}}

{{/*
Create the name of the repo-server service account to use
*/}}
{{- define "argo-cd.repoServer.serviceAccountName" -}}
{{- if .Values.repoServer.serviceAccount.create -}}
    {{ default (include "argo-cd.repoServer.fullname" .) .Values.repoServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.repoServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create argocd application set name and version as used by the chart label.
*/}}
{{- define "argo-cd.applicationSet.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.applicationSet.name) -}}
{{- end -}}

{{/*
Create the name of the application set service account to use
*/}}
{{- define "argo-cd.applicationSet.serviceAccountName" -}}
{{- if .Values.applicationSet.serviceAccount.create -}}
    {{ default (include "argo-cd.applicationSet.fullname" .) .Values.applicationSet.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.applicationSet.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create argocd notifications name and version as used by the chart label.
*/}}
{{- define "argo-cd.notifications.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.notifications.name) -}}
{{- end -}}

{{/*
Create the name of the notifications service account to use
*/}}
{{- define "argo-cd.notifications.serviceAccountName" -}}
{{- if .Values.notifications.serviceAccount.create -}}
    {{ default (include "argo-cd.notifications.fullname" .) .Values.notifications.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.notifications.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create argocd commit-server name and version as used by the chart label.
*/}}
{{- define "argo-cd.commitServer.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.commitServer.name) -}}
{{- end -}}

{{/*
Create the name of the commit-server service account to use
*/}}
{{- define "argo-cd.commitServer.serviceAccountName" -}}
{{- if .Values.commitServer.serviceAccount.create -}}
    {{ default (include "argo-cd.commitServer.fullname" .) .Values.commitServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.commitServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Argo Configuration Preset Values (Influenced by Values configuration)
*/}}
{{- define "argo-cd.config.cm.presets" -}}
{{- $presets := dict -}}
{{- $_ := set $presets "url" (printf "https://%s" .Values.global.domain) -}}
{{- if eq (toString (index .Values.configs.cm "statusbadge.enabled")) "true" -}}
{{- $_ := set $presets "statusbadge.url" (printf "https://%s/" .Values.global.domain) -}}
{{- end -}}
{{- if .Values.configs.styles -}}
{{- $_ := set $presets "ui.cssurl" "./custom/custom.styles.css" -}}
{{- end -}}
{{- toYaml $presets }}
{{- end -}}

{{/*
Merge Argo Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config.cm" -}}
{{- $config := omit .Values.configs.cm "create" "annotations" -}}
{{- $preset := include "argo-cd.config.cm.presets" . | fromYaml | default dict -}}
{{- range $key, $value := mergeOverwrite $preset $config }}
{{- $fmted := $value | toString }}
{{- if not (eq $fmted "") }}
{{ $key }}: {{ $fmted | toYaml }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Argo Params Default Configuration Presets
NOTE: Configuration keys must be stored as dict because YAML treats dot as separator
*/}}
{{- define "argo-cd.config.params.presets" -}}
{{- $presets := dict -}}
{{- $_ := set $presets "repo.server" (printf "%s:%s" (include "argo-cd.repoServer.fullname" .) (.Values.repoServer.service.port | toString)) -}}
{{- $_ := set $presets "server.repo.server.strict.tls" (.Values.repoServer.certificateSecret.enabled | toString ) -}}
{{- $_ := set $presets "redis.server" (include "argo-cd.redis.server" .) -}}
{{- $_ := set $presets "applicationsetcontroller.enable.leader.election" (gt ((.Values.applicationSet.replicas | default .Values.applicationSet.replicaCount) | int64) 1) -}}
{{- if .Values.dex.enabled -}}
{{- $_ := set $presets "server.dex.server" (include "argo-cd.dex.server" .) -}}
{{- $_ := set $presets "server.dex.server.strict.tls" .Values.dex.certificateSecret.enabled -}}
{{- end -}}
{{- if .Values.commitServer.enabled -}}
{{- $_ := set $presets "commit.server" (printf "%s:%s" (include "argo-cd.commitServer.fullname" .) (.Values.commitServer.service.port | toString)) -}}
{{- end -}}
{{- range $component := tuple "applicationsetcontroller" "controller" "server" "reposerver" "notificationscontroller" "dexserver" "commitserver" -}}
{{- $_ := set $presets (printf "%s.log.format" $component) $.Values.global.logging.format -}}
{{- $_ := set $presets (printf "%s.log.level" $component) $.Values.global.logging.level -}}
{{- end -}}
{{- toYaml $presets }}
{{- end -}}

{{/*
Merge Argo Params Configuration with Preset Configuration
*/}}
{{- define "argo-cd.config.params" -}}
{{- $config := omit .Values.configs.params "create" "annotations" }}
{{- $preset := include "argo-cd.config.params.presets" . | fromYaml | default dict -}}
{{- range $key, $value := mergeOverwrite $preset $config }}
{{ $key }}: {{ toString $value | toYaml }}
{{- end }}
{{- end -}}

{{/*
Expand the namespace of the release.
Allows overriding it for multi-namespace deployments in combined charts.
*/}}
{{- define "argo-cd.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Dual stack definition
*/}}
{{- define "argo-cd.dualStack" -}}
{{- with .Values.global.dualStack.ipFamilyPolicy }}
ipFamilyPolicy: {{ . }}
{{- end }}
{{- with .Values.global.dualStack.ipFamilies }}
ipFamilies: {{ toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{/*
secretKeyRef of env variable REDIS_USERNAME
*/}}
{{- define "argo-cd.redisUsernameSecretRef" -}}
    {{- if .Values.externalRedis.host -}}
name: {{ default "argocd-redis" .Values.externalRedis.existingSecret }}
key: redis-username
optional: {{ if .Values.externalRedis.username }}false{{ else }}true{{ end }}

    {{- else -}}
name: "argocd-redis"
key: redis-username
optional: true
    {{- end -}}
{{- end -}}

{{/*
secretKeyRef of env variable REDIS_PASSWORD
*/}}
{{- define "argo-cd.redisPasswordSecretRef" -}}
    {{- if .Values.externalRedis.host -}}
    {{- /* External Redis use case */ -}}
    {{- /* Secret is required when specifying existingSecret or a password, otherwise it is optional */ -}}
name: {{ default "argocd-redis" .Values.externalRedis.existingSecret }}
key: redis-password
optional: {{ if or .Values.externalRedis.existingSecret .Values.externalRedis.password }}false{{ else }}true{{ end }}

    {{- else if and .Values.redisSecretInit.enabled -}}
    {{- /* Default case where Secret is generated by the Job with Helm pre-install hooks */ -}}
name: "argocd-redis" # hard-coded in Job command and embedded Redis deployments (standalone and redis-ha)
key: auth
optional: false # Secret is not optional in this case !

    {{- else -}}
    {{- /* All other use cases (e.g. disabled pre-install Job) */ -}}
name: "argocd-redis"
key: auth
optional: true
    {{- end -}}
{{- end -}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "argo-cd.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride }}
{{- end -}}

{{/*
Return the appropriate apiVersion for monitoring CRDs
*/}}
{{- define "argo-cd.apiVersions.monitoring" -}}
{{- if .Values.apiVersionOverrides.monitoring -}}
{{- print .Values.apiVersionOverrides.monitoring -}}
{{- else -}}
{{- print "monitoring.coreos.com/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create controller metrics service name.
*/}}
{{- define "argo-cd.controller.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.controller.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create redis metrics service name.
*/}}
{{- define "argo-cd.redis.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.redis.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create server metrics service name.
*/}}
{{- define "argo-cd.server.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.server.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create repo-server metrics service name.
*/}}
{{- define "argo-cd.repoServer.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.repoServer.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create applicationset metrics service name.
*/}}
{{- define "argo-cd.applicationSet.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.applicationSet.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create notifications metrics service name.
*/}}
{{- define "argo-cd.notifications.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.notifications.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create commit-server metrics service name.
*/}}
{{- define "argo-cd.commitServer.metrics.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.commitServer.name "suffix" "metrics") -}}
{{- end -}}

{{/*
Create redis health configmap name.
*/}}
{{- define "argo-cd.redis.healthConfigMap.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.redis.name "suffix" "health-configmap") -}}
{{- end -}}

{{/*
Create server grpc service/ingress name.
*/}}
{{- define "argo-cd.server.grpc.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.server.name "suffix" "grpc") -}}
{{- end -}}


{{/*
Create aws server grpc service/ingress name.
*/}}
{{- define "argo-cd.server.aws.grpc.fullname" -}}
{{- include "argo-cd.component.fullname" (dict "context" . "name" .Values.server.name "suffix" "grpc" "maxLen" 52) -}}
{{- end -}}
