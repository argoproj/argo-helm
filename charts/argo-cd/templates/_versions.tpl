{{/* vim: set filetype=mustache: */}}
{{/*
Return the target Kubernetes version
*/}}
{{- define "argo-cd.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride }}
{{- end }}

{{/*
Return the appropriate apiVersion for autoscaling
*/}}
{{- define "argo-cd.apiVersion.autoscaling" -}}
{{- if .Values.apiVersionOverrides.autoscaling -}}
{{- print .Values.apiVersionOverrides.autoscaling -}}
{{- else if semverCompare "<1.23-0" (include "argo-cd.kubeVersion" .) -}}
{{- print "autoscaling/v2beta1" -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for GKE resources
*/}}
{{- define "argo-cd.apiVersions.cloudgoogle" -}}
{{- if .Values.apiVersionOverrides.cloudgoogle -}}
{{- print .Values.apiVersionOverrides.cloudgoogle -}}
{{- else if .Capabilities.APIVersions.Has "cloud.google.com/v1" -}}
{{- print "cloud.google.com/v1" -}}
{{- else -}}
{{- print "cloud.google.com/v1beta1" -}}
{{- end -}}
{{- end -}}
