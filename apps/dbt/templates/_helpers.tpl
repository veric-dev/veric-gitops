{{- define "dbt.labels" -}}
app.kubernetes.io/name: dbt
app.kubernetes.io/managed-by: argocd
{{- end -}}

{{- define "dbt.selectorLabels" -}}
app.kubernetes.io/name: dbt
{{- end -}}
