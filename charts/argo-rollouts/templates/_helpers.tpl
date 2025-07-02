{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "argo-rollouts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-rollouts.fullname" -}}
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
{{- define "argo-rollouts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create kubernetes friendly chart version label.

Examples:
image.tag = v1.3.1
output    = v1.3.1

image.tag = v1.3.1@sha256:38828e693b02e6f858d89fa22a9d9811d3d7a2430a1d4c7d687b6f509775c6ce
output    = v1.3.1
*/}}
{{- define "argo-rollouts.chart_version_label" -}}
{{- regexReplaceAll "[^a-zA-Z0-9-_.]+" (regexReplaceAll "@sha256:[a-f0-9]+" (default .Chart.AppVersion $.Values.controller.image.tag) "") "" | trunc 63 | quote -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "argo-rollouts.labels" -}}
helm.sh/chart: {{ include "argo-rollouts.chart" . }}
{{ include "argo-rollouts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ include "argo-rollouts.chart_version_label" . }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: argo-rollouts
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-rollouts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argo-rollouts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argo-rollouts.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argo-rollouts.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress
*/}}
{{- define "argo-rollouts.ingress.apiVersion" -}}
{{- if .Values.apiVersionOverrides.ingress -}}
{{- print .Values.apiVersionOverrides.ingress -}}
{{- else if semverCompare "<1.14-0" (include "argo-rollouts.kubeVersion" $) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "argo-rollouts.kubeVersion" $) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "argo-rollouts.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride }}
{{- end -}}

{{/*
Return the appropriate apiVersion for pod disruption budget
*/}}
{{- define "argo-rollouts.podDisruptionBudget.apiVersion" -}}
{{- if semverCompare "<1.21-0" (include "argo-rollouts.kubeVersion" $) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the rules for controller's Role and ClusterRole
*/}}
{{- define "argo-rollouts.controller.roleRules" -}}
- apiGroups:
  - argoproj.io
  resources:
  - rollouts
  - rollouts/status
  - rollouts/finalizers
  verbs:
  - get
  - list
  - watch
  - update
  - patch
- apiGroups:
  - argoproj.io
  resources:
  - analysisruns
  - analysisruns/finalizers
  - experiments
  - experiments/finalizers
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - argoproj.io
  resources:
  - analysistemplates
  - clusteranalysistemplates
  verbs:
  - get
  - list
  - watch
# replicaset access needed for managing ReplicaSets
- apiGroups:
  - apps
  resources:
  - replicasets
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
# deployments and podtemplates read access needed for workload reference support
- apiGroups:
  - ""
  - apps
  resources:
  - deployments
  - podtemplates
  verbs:
  - get
  - list
  - watch
  - update
# services patch needed to update selector of canary/stable/active/preview services
# services create needed to create and delete services for experiments
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - list
  - watch
  - patch
  - create
  - delete
# leases create/get/update needed for leader election
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - create
  - get
  - update
# secret read access to run analysis templates which reference secrets
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - list
  - watch
{{- if .Values.providerRBAC.providers.gatewayAPI }}
  - create
  - update
{{- end }}
# pod list/update needed for updating ephemeral data
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - list
  - update
  - watch
# pods eviction needed for restart
- apiGroups:
  - ""
  resources:
  - pods/eviction
  verbs:
  - create
# event write needed for emitting events
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - update
  - patch
# ingress patch needed for managing ingress annotations, create needed for nginx canary
- apiGroups:
  - networking.k8s.io
  - extensions
  resources:
  - ingresses
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
# job access needed for analysis template job metrics
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
{{- if .Values.providerRBAC.enabled }}
{{- if .Values.providerRBAC.providers.istio }}
# virtualservice/destinationrule access needed for using the Istio provider
- apiGroups:
  - networking.istio.io
  resources:
  - virtualservices
  - destinationrules
  verbs:
  - watch
  - get
  - update
  - patch
  - list
{{- end }}
{{- if .Values.providerRBAC.providers.smi }}
# trafficsplit access needed for using the SMI provider
- apiGroups:
  - split.smi-spec.io
  resources:
  - trafficsplits
  verbs:
  - create
  - watch
  - get
  - update
  - patch
{{- end }}
{{- if .Values.providerRBAC.providers.ambassador }}
# ambassador access needed for Ambassador provider
- apiGroups:
  - getambassador.io
  - x.getambassador.io
  resources:
  - mappings
  - ambassadormappings
  verbs:
  - create
  - watch
  - get
  - update
  - list
  - delete
{{- end }}
{{- if .Values.providerRBAC.providers.awsLoadBalancerController }}
# Endpoints and TargetGroupBindings needed for ALB target group verification when using AWS Load Balancer Controller
- apiGroups:
  - ""
  resources:
  - endpoints
  verbs:
  - get
- apiGroups:
  - elbv2.k8s.aws
  resources:
  - targetgroupbindings
  verbs:
  - list
  - get
{{- end }}
{{- if .Values.providerRBAC.providers.awsAppMesh }}
# AppMesh virtualservices/virtualrouter CRD read-only access needed for using the App Mesh provider
- apiGroups:
  - appmesh.k8s.aws
  resources:
  - virtualservices
  verbs:
  - watch
  - get
  - list
# AppMesh virtualnode CRD r/w access needed for using the App Mesh provider
- apiGroups:
  - appmesh.k8s.aws
  resources:
  - virtualnodes
  - virtualrouters
  verbs:
  - watch
  - get
  - list
  - update
  - patch
{{- end }}
{{- if .Values.providerRBAC.providers.traefik }}
# Traefik access needed when using the Traefik provider
- apiGroups:
  - traefik.containo.us
  - traefik.io
  resources:
  - traefikservices
  verbs:
  - watch
  - get
  - update
{{- end }}
{{- if .Values.providerRBAC.providers.apisix }}
# Access needed when using the Apisix provider
- apiGroups:
  - apisix.apache.org
  resources:
  - apisixroutes
  verbs:
  - watch
  - get
  - update
{{- end }}
{{- if .Values.providerRBAC.providers.contour }}
  # Access needed when using the Contour provider
- apiGroups:
  - projectcontour.io
  resources:
  - httpproxies
  verbs:
  - get
  - list
  - watch
  - update
{{- end }}
{{- if .Values.providerRBAC.providers.glooPlatform }}
  # Access needed when using the Gloo Platform provider
- apiGroups:
  - networking.gloo.solo.io
  resources:
  - routetables
  verbs:
  - '*'
{{- end }}
{{- if .Values.providerRBAC.providers.gatewayAPI }}
  # Access needed when using the Gateway API provider
- apiGroups:
  - gateway.networking.k8s.io
  resources:
  - httproutes
  - tcproutes
  - tlsroutes
  - udproutes
  - grpcroutes
  verbs:
  - get
  - list
  - watch
  - update
{{- end }}
{{- with .Values.providerRBAC.additionalRules }}
{{ toYaml .  }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Expand the namespace of the release.
*/}}
{{- define "argo-rollouts.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}
