{{- define "web.labels" -}}
app.kubernetes.io/name: web
app.kubernetes.io/managed-by: argocd
{{- end -}}

{{- define "web.selectorLabels" -}}
app.kubernetes.io/name: web
{{- end -}}
