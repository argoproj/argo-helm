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
Return the appropriate apiVersion for ingress
*/}}
{{- define "argo-cd.apiVersion.ingress" -}}
{{- if .Values.apiVersionOverrides.ingress -}}
{{- print .Values.apiVersionOverrides.ingress -}}
{{- else if semverCompare "<1.14-0" (include "argo-cd.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "argo-cd.kubeVersion" .) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for pod disruption budget
*/}}
{{- define "argo-cd.apiVersion.pdb" -}}
{{- if .Values.apiVersionOverrides.pdb -}}
{{- print .Values.apiVersionOverrides.pdb -}}
{{- else if semverCompare "<1.21-0" (include "argo-cd.kubeVersion" .) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cert-manager
*/}}
{{- define "argo-cd.apiVersion.cert-manager" -}}
{{- if .Values.apiVersionOverrides.certmanager -}}
{{- print .Values.apiVersionOverrides.certmanager -}}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1" -}}
{{- print "cert-manager.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" -}}
{{- print "cert-manager.io/v1alpha3" -}}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha2" -}}
{{- print "cert-manager.io/v1alpha2" -}}
{{- else -}}
{{- print "certmanager.k8s.io/v1alpha1" -}}
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
