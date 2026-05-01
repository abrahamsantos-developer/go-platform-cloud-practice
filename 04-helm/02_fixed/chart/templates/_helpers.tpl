{{- define "goose.name" -}}
goose
{{- end -}}

{{- define "goose.fullname" -}}
{{- default (include "goose.name" .) .Release.Name -}}
{{- end -}}
