<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# fluentd

![Version: 0.3.8-bb.0](https://img.shields.io/badge/Version-0.3.8--bb.0-informational?style=flat-square) ![AppVersion: v1.14.2](https://img.shields.io/badge/AppVersion-v1.14.2-informational?style=flat-square)

A Helm chart for Kubernetes

## Upstream References
- <https://www.fluentd.org/>

* <https://github.com/fluent/fluentd/>
* <https://github.com/fluent/fluentd-kubernetes-daemonset>

## To Test
The sample values.yaml below can be used with the `master` Big Bang branch to test fluentd deployment

### Testing without Elasticsearch
```
istioCRDs:
  enabled: true
istiod:
  enabled: true
  values:
    hardened:
      enabled: true

networkPolicies:
  enabled: true

kyvernoPolicies:
  enabled: true
  values:
    policies:
      require-non-root-group:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      add-default-securitycontext:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      require-non-root-user:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-host-path-mount:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-host-path-write:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-volume-types:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*

packages:
  # This will be used as the namespace for the install, as well as the name of the helm release. If this is changed, the destination service (below) needs to also be changed.
  fluentd:
    enabled: true
    git:
      repo: https://repo1.dso.mil/big-bang/product/maintained/fluentd.git
      # It is recommended to update this to the latest bb tag
      tag: null
      branch: <insert test branch>
    helmRelease:
      namespace: bigbang    
    istio:
      injection: enabled
    values:
      networkPolicies:
        enabled: true
      istio:
        enabled: true
        hardened:
          enabled: true
```
### Testing with Elasticsearch
For more step by step documentation on [Big Bang Elasticsearch integration](https://repo1.dso.mil/big-bang/apps/sandbox/fluentd/-/blob/25-ek/docs/Elasticsearch_Integration.md)
```
elasticsearchKibana:
  enabled: true

eckOperator:
  enabled: true

istioCRDs:
  enabled: true
istiod:
  enabled: true
  values:
    hardened:
      enabled: true

networkPolicies:
  enabled: true

monitoring:
  enabled: true

grafana:
  enabled: true

kyvernoPolicies:
  enabled: true
  values:
    policies:
      require-non-root-group:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      add-default-securitycontext:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      require-non-root-user:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-host-path-mount:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-host-path-write:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      restrict-volume-types:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*

packages:
  # This will be used as the namespace for the install, as well as the name of the helm release. If this is changed, the destination service (below) needs to also be changed.
  fluentd:
    enabled: true
    git:
      repo: https://repo1.dso.mil/big-bang/product/maintained/fluentd.git
      # It is recommended to update this to the latest bb tag
      tag: null
      branch: <insert test branch>
    helmRelease:
      namespace: bigbang
    dependsOn:
      - name: ek
        namespace: bigbang
      - name: monitoring
        namespace: bigbang
    postRenderers:
      - kustomize:
          patches:
            # Required Patches for Prometheus ServiceMonitor scraping
            - patch: |
                - op: add
                  path: /spec/endpoints/0/enableHttp2
                  value: false
                - op: add
                  path: /spec/endpoints/0/scheme
                  value: https
                - op: add
                  path: /spec/endpoints/0/tlsConfig
                  value:
                    caFile: /etc/prom-certs/root-cert.pem
                    certFile: /etc/prom-certs/cert-chain.pem
                    insecureSkipVerify: true
                    keyFile: /etc/prom-certs/key.pem
              target:
                kind: ServiceMonitor
                name: fluentd
    istio:
      injection: enabled
    values:
      networkPolicies:
        enabled: true
      istio:
        enabled: true
        hardened:
          enabled: true
      elasticsearch:
        enabled: true
      upstream:
        env:
          - name: FLUENT_ELASTICSEARCH_HOST
            value: logging-ek-es-http.logging.svc.cluster.local
          - name: FLUENT_ELASTICSEARCH_PORT
            value: "9200"
          - name: FLUENT_ELASTICSEARCH_USER
            value: elastic
          - name: FLUENT_ELASTICSEARCH_PASSWORD
            valueFrom:
              secretKeyRef:
                name: elasticsearch-credentials  # Do not change
                key: es_password                 # Do not change
        metrics:
          serviceMonitor:
            enabled: true
        dashboards:
          enabled: true
        volumes:
          - name: elasticsearch-cert
            secret:
              secretName: elasticsearch-cert

        volumeMounts:
          - name: elasticsearch-cert
            mountPath: /etc/elasticsearch/certs/

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
                ca_file /etc/elasticsearch/certs/ca.crt
                custom_headers {
                  "Accept":"application/vnd.elasticsearch+json; compatible-with=9",
                  "Content-Type":"application/vnd.elasticsearch+json; compatible-with=9"
                }
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
                custom_headers {
                  "Accept":"application/vnd.elasticsearch+json; compatible-with=9",
                  "Content-Type":"application/vnd.elasticsearch+json; compatible-with=9"
                }
                <buffer>
                  @type file
                  path /var/log/fluentd-buffers/es-host
                  total_limit_size 10GB
                  flush_interval 5s
                </buffer>
              </match>
            </label>
```

Testing Steps:
- Login to Kibana, then navigate to https://kibana.dev.bigbang.mil/app/management/kibana/indexPatterns and create a data view for logstash-*
- Navigate to Analytics -> Discover and validate that pod logs are appearing in the logstash index pattern
- Login to Grafana, then navigate to `Dashboards` > `Fluentd 1.x` and validate that the dashboard displays data

