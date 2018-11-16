{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sensor-crd-json" }}
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "name": "sensors.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "Sensor",
      "listKind": "SensorList",
      "plural": "sensors",
      "singular": "sensor"
    },
    "scope": "Namespaced",
    "version": "v1alpha1"
  }
}
{{- end}}
