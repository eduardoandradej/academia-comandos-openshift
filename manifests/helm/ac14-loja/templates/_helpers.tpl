{{/* Nome dos objetos: o próprio nome da release (até 63 caracteres). */}}
{{- define "ac14-loja.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Rótulos comuns, inclusive o da Academia. */}}
{{- define "ac14-loja.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
academy.openshift.dev/managed-by: academia
{{- end -}}

{{/* Rótulos de seleção: estáveis entre versões do chart (seletores são imutáveis). */}}
{{- define "ac14-loja.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Imagem: digest tem prioridade sobre a tag. */}}
{{- define "ac14-loja.image" -}}
{{- if .Values.image.digest -}}
{{ .Values.image.repository }}@{{ .Values.image.digest }}
{{- else -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}
