{{/*
Create the image reference
Prioritizes digest over tag if digest is provided and not empty
*/}}
{{- define "datapower-nano-operator.image" -}}
{{- if and .Values.image.digest (ne .Values.image.digest "") }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
{{- end }}
