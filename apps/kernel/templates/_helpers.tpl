{{- define "kernel.labels" -}}
app.kubernetes.io/name: kernel
app.kubernetes.io/managed-by: argocd
{{- end -}}

{{- define "kernel.selectorLabels" -}}
app.kubernetes.io/name: kernel
{{- end -}}
