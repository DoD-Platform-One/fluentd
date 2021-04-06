{{- define "fluentd.pod" -}}
{{- $defaultTag := printf "%s-debian-elasticsearch" (.Chart.AppVersion) -}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- end }}
serviceAccountName: {{ include "fluentd.serviceAccountName" . }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
containers:
  - name: {{ .Chart.Name }}
    securityContext:
      {{- toYaml .Values.securityContext | nindent 6 }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default $defaultTag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
  # Commenting out to remove support for plugin installation at runtime
  # {{- if .Values.plugins }}
  #   command:
  #   - "/bin/sh"
  #   - "-c"
  #   - |
  #     {{- range $plugin := .Values.plugins }}
  #       {{- print "fluent-gem install " $plugin | nindent 6 }}
  #     {{- end }}
  #     exec ./entrypoint.sh
  # {{- end }}
  {{- if .Values.env }}
    env:
      - name: FLUENT_ELASTICSEARCH_HOST
        value: {{ tpl .Values.elasticsearch.host . }}
      - name: FLUENT_ELASTICSEARCH_PORT
        value: {{ .Values.elasticsearch.port | quote }}
      - name: FLUENT_ELASTICSEARCH_USER
        value: {{ .Values.elasticsearch.user }}
      - name: FLUENT_ELASTICSEARCH_PASSWORD
      {{- if .Values.elasticsearch.elastic_password }}
        value: {{ .Values.elasticsearch.elastic_password }}
      {{ else }}
        valueFrom:
          secretKeyRef:
            name: elasticsearch-credentials
            key: es_password
      {{- end }}
    {{- toYaml .Values.env | nindent 6 }}
  {{- end }}
  {{- if .Values.envFrom }}
    envFrom:
    {{- toYaml .Values.envFrom | nindent 6 }}
  {{- end }}
    ports:
    - name: metrics
      containerPort: 24231
      protocol: TCP
    {{- range $port := .Values.service.ports }}
    - name: {{ $port.name }}
      containerPort: {{ $port.containerPort }}
      protocol: {{ $port.protocol }}
    {{- end }}
    livenessProbe:
      httpGet:
        path: /metrics
        port: metrics
    readinessProbe:
      httpGet:
        path: /metrics
        port: metrics
    resources:
      {{- toYaml .Values.resources | nindent 8 }}
    volumeMounts:
      {{- toYaml .Values.volumeMounts | nindent 6 }}
      {{- range $key := .Values.configMapConfigs }}
      {{- print "- name: fluentd-custom-cm-" $key  | nindent 6 }}
        {{- print "mountPath: /fluentd/etc/" $key ".d"  | nindent 8 }}
      {{- end }}
volumes:
  {{- toYaml .Values.volumes | nindent 2 }}
  {{- range $key := .Values.configMapConfigs }}
  {{- print "- name: fluentd-custom-cm-" $key  | nindent 2 }}
    configMap:
      {{- print "name: " .  | nindent 6 }}
      defaultMode: 0777
  {{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
