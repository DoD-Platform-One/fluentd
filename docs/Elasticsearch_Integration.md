#  How to Enable Fluentd Integration with Big Bang Elasticsearch

Follow these steps to configure Fluentd to send logs to Big Bang-managed Elasticsearch.

---
## 1. Enable Elasticsearch in the values.yaml
Set enable to true under elasticsearch
```
## Additional values to support Big Bang Elasticsearch integration
elasticsearch:
  enabled: true
```
---

## 2. Set the Elasticsearch Host and Port

Add the following block under `fluentd.env` and update it if necessary:

```yaml
# fluentd:
  env:
    - name: FLUENT_ELASTICSEARCH_HOST
      value: logging-ek-es-http.logging.svc.cluster.local
    - name: FLUENT_ELASTICSEARCH_PORT
      value: "9200"
```

These values assume your Big Bang Elasticsearch is deployed in the `logging` namespace using its default naming convention.

---

## 3. Set the Elasticsearch Authentication Credentials

Still under `fluentd.env`, Add the following:

```yaml
# fluentd:
#   env:
    - name: FLUENT_ELASTICSEARCH_USER
      value: elastic
```

Then choose **one** of the following authentication options:

### Option A (Recommended): Use Secret Managed by This Chart

Add this block:

```yaml
# fluentd:
#   env:
    - name: FLUENT_ELASTICSEARCH_PASSWORD
      valueFrom:
        secretKeyRef:
          name: elasticsearch-credentials  # Do not change
          key: es_password                 # Do not change
```

 This secret (`elasticsearch-credentials`) is automatically created by the chart using Helm’s `lookup` to extract the password from the `logging` namespace.

### Option B (Manual): Provide Password Inline

Alternatively, for dev/testing only, you may hardcode the password (not recommended):

```yaml
# fluentd:
#   env:
    - name: FLUENT_ELASTICSEARCH_PASSWORD
      value: "your-password"
```

---

## 4. Mount the Elasticsearch Certificate (for TLS)

To trust the Big Bang Elasticsearch certificate, add:

```yaml
# fluentd:
  volumes:
    - name: elasticsearch-cert
      secret:
        secretName: elasticsearch-cert

  volumeMounts:
    - name: elasticsearch-cert
      mountPath: /etc/elasticsearch/certs/
```

This chart will auto-create the `elasticsearch-cert` secret by copying from the `logging` namespace.

---

## 5. Enable Elasticsearch Output in Fluentd

Finally, Add the `fileConfigs` block:

```yaml
# fluentd:
  fileConfigs:
    02_filters.conf: |-
      <label @KUBERNETES>
        <match kubernetes.var.log.containers.fluentd**>
          @type relabel
          @label @FLUENT_LOG
        </match>
        <filter kubernetes.**>
          @type kubernetes_metadata
          @id filter_kube_metadata
          skip_pod_labels true
        </filter>
        <match **>
          @type relabel
          @label @DISPATCH
        </match>
      </label>

    04_outputs.conf: |-
      <label @OUTPUT>
        <match kubernetes.**>
          @type elasticsearch
          host logging-ek-es-http.logging
          port 9200
          scheme https
          user elastic
          password "#{ENV['FLUENT_ELASTICSEARCH_PASSWORD']}"
          logstash_format true
          suppress_type_name true
          include_tag_key true
          replace_dots true
          ca_file /etc/elasticsearch/certs/ca.crt
          <buffer>
            @type file
            path /var/log/fluentd-buffers/es-kube
            total_limit_size 10GB
            flush_interval 5s
          </buffer>
        </match>

        <match host.**>
          @type elasticsearch
          host logging-ek-es-http.logging
          port 9200
          scheme https
          user elastic
          password "#{ENV['FLUENT_ELASTICSEARCH_PASSWORD']}"
          logstash_format true
          suppress_type_name true
          logstash_prefix node
          ca_file /etc/elasticsearch/certs/ca.crt
          <buffer>
            @type file
            path /var/log/fluentd-buffers/es-host
            total_limit_size 10GB
            flush_interval 5s
          </buffer>
        </match>
      </label>
```

---

##  Done

Once these changes are saved, deploy or upgrade the Helm release. Fluentd will route Kubernetes and host logs to Big Bang Elasticsearch using the secrets and certificates managed by this chart.
