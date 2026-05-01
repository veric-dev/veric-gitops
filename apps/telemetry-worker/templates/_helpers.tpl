{{- define "telemetry-worker.labels" -}}
app.kubernetes.io/name: telemetry-worker
app.kubernetes.io/managed-by: argocd
{{- end -}}

{{- define "telemetry-worker.selectorLabels" -}}
app.kubernetes.io/name: telemetry-worker
{{- end -}}
