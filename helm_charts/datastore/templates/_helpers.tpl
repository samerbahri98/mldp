{{/*
Expand the name of the chart.
*/}}
{{- define "datastore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datastore.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "datastore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "datastore.labels" -}}
helm.sh/chart: {{ include "datastore.chart" . }}
app.kubernetes.io/name: {{ include "datastore.name" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml .  }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "datastore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datastore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "datastore.gatewayHttpRoutes" -}}
{{- if .Values.gatewayHttpRoutes.enabled -}}
{{- if .Values.gatewayHttpRoutes.minioConsole.enabled -}}
minioConsole:
  service: {{ template "common.names.fullname" .Subcharts.minio }}
  labels: {{ .Values.gatewayHttpRoutes.labels | default (dict) }}
  annotations: {{ .Values.gatewayHttpRoutes.annotations | default (dict) }}
  port: {{ .Values.minio.service.ports.console }}
{{- end }}
{{- if .Values.gatewayHttpRoutes.pgadmin4.enabled }}
pgadmin4:
  service: {{ template "datastore.fullname" .Subcharts.pgadmin4 }}
  labels: {{ .Values.gatewayHttpRoutes.labels | default (dict) }}
  annotations: {{ .Values.gatewayHttpRoutes.annotations | default (dict) }}
  port: {{ .Values.pgadmin4.service.port }}
{{- end }}
{{- if .Values.gatewayHttpRoutes.redisinsight.enabled }}
redisinsight:
  service: {{ template "datastore.fullname" .Subcharts.redisinsight }}
  labels: {{ .Values.gatewayHttpRoutes.labels | default (dict) }}
  annotations: {{ .Values.gatewayHttpRoutes.annotations | default (dict) }}
  port: {{ .Values.redisinsight.service.port }}
{{- end }}
{{- end }}
{{- end }}

{{- define "datastore.gatewayHostnames" -}}
{{- $hostnames := (index .context.Values.gatewayHttpRoutes .key ).hostnames -}}
{{- if $hostnames -}}
{{- range $i := $hostnames -}}
- {{ $i }}
{{- end }}
{{- else -}}
[]
{{- end }}
{{- end }}

{{- define "datastore.gatewayParentRefs" -}}
{{- $parentRefs := (index .context.Values.gatewayHttpRoutes .key ).parentRefs -}}
{{- if $parentRefs -}}
{{- range $i := $parentRefs -}}
- name: {{ $i.name }}
{{- if $i.namespace }}
  namespace: {{ $i.namespace }}
{{- end }}
{{- end }}
{{- else -}}
[]
{{- end }}
{{- end }}


  # parentRefs: {{ .Values.gatewayHttpRoutes.minioConsole.parentRefs | default (list) }}
  # parentRefs: {{ .Values.gatewayHttpRoutes.minioConsole.parentRefs | default (list) }}
  # hostnames: {{ .Values.gatewayHttpRoutes.minioConsole.hostnames | default (list) }}
  # labels: {{ .Values.gatewayHttpRoutes.labels }}
  # annotations: {{ .Values.gatewayHttpRoutes.annotations }}
  # service: {{ template "common.names.fullname" .Subcharts.minio }}
  # port: {{ .Values.minio.service.ports.console }}
