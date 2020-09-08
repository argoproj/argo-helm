{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified app name without the override capability.
Used for cluster-scoped resources which cannot share the common override name
when installed from different releases of the same chart in different
namespaces.
*/}}
{{- define "fullnamenooverride" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "fullnamenooverride" . -}}
{{- end -}}
{{- end -}}

/*
Create a fully qualified name for Argo server.
*/
{{- define "serverfullname" -}}
{{- include "fullname" . -}}-{{- .Values.server.name -}}
{{- end -}}

Create a fully qualified name for Argo server, without overridde support.
*/
{{- define "serverfullnamenooverride" -}}
{{- include "fullnamenooverride" . -}}-{{- .Values.server.name -}}
{{- end -}}

/*
Create a fully qualified name for Argo workflow controller.
*/
{{- define "controllerfullname" -}}
{{- include "fullname" . -}}-{{- .Values.controller.name -}}
{{- end -}}

Create a fully qualified name for Argo workflow controller, without overridde
support.
*/
{{- define "controllerfullnamenooverride" -}}
{{- include "fullnamenooverride" . -}}-{{- .Values.controller.name -}}
{{- end -}}
