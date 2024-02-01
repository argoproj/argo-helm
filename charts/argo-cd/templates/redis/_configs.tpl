{{/* vim: set filetype=mustache: */}}

{{- define "redis_liveness.sh" }}
    response=$(
      redis-cli \
        -h localhost \
        -p {{ .Values.redis.containerPorts.redis }} \
        ping
    )
    if [ "$response" != "PONG" ] && [ "${response:0:7}" != "LOADING" ] ; then
      echo "$response"
      exit 1
    fi
    echo "response=$response"
{{- end }}

{{- define "redis_readiness.sh" }}
    response=$(
      redis-cli \
        -h localhost \
        -p {{ .Values.redis.containerPorts.redis }} \
        ping
    )
    if [ "$response" != "PONG" ] ; then
      echo "$response"
      exit 1
    fi
    echo "response=$response"
{{- end }}
