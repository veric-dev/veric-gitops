{{- define "web.labels" -}}
app.kubernetes.io/name: web
app.kubernetes.io/managed-by: argocd
{{- end -}}

{{- define "web.selectorLabels" -}}
app.kubernetes.io/name: web
{{- end -}}

{{- define "web.podSpec" -}}
serviceAccountName: {{ .Values.serviceAccount.name }}
containers:
  - name: web
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    ports:
      - name: http
        containerPort: {{ .Values.service.targetPort }}
        protocol: TCP
    env:
      {{- range $k, $v := .Values.env }}
      - name: {{ $k }}
        value: {{ $v | quote }}
      {{- end }}
    {{- if .Values.externalSecrets.enabled }}
    envFrom:
      - secretRef:
          name: web-env
    {{- end }}
    livenessProbe:
      {{- toYaml .Values.probes.liveness | nindent 6 }}
    readinessProbe:
      {{- toYaml .Values.probes.readiness | nindent 6 }}
    resources:
      {{- toYaml .Values.resources | nindent 6 }}
{{- end -}}
