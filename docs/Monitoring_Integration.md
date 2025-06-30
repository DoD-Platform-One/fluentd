#  How to Enable Monitoring Integration for Fluentd

This guide explains how to configure Fluentd to expose metrics for Prometheus scraping and automatically provision Grafana dashboards for monitoring visualization.

**NOTE:** This guide assumes you will be using the Big Bang [Monitoring Chart](https://repo1.dso.mil/big-bang/product/packages/monitoring)

## 1. Enable Metrics Collection and Dashboard Creation

- Set `.Values.packages.fluentd.values.upstream.metrics.serviceMonitor.enabled=true`
- Set `.Values.packages.fluentd.values.upstream.dashboards.enabled=true`
- (RECOMMENDED) Add monitoring dependency `.Values.packages.fluentd.dependsOn`

```yaml
packages:
  fluentd:
    dependsOn:
      # Ensure the Big Bang monitoring chart is installed
      # before trying to utilize Prometheus and Grafana
      - name: monitoring
        namespace: bigbang
    values:
      upstream:
        metrics:
          # Create ServiceMonitor resource for Prometheus Scraping
          serviceMonitor:
            enabled: true
        # Create Grafana dashboard configMap
        dashboards:
          enabled: true
```

## 2. Configure Scraping over TLS

The upstream Fluentd chart does not expose the ServiceMonitor configurations required for configurations for TLS

Add the following postRenderer configuration to automatically apply the necessary settings to the Fluentd ServiceMonitor:

```yaml
packages:
  fluentd:
    postRenderers:
      - kustomize:
          patches:
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
```

## 3. Verification

After applying this configuration:

1. Check that the ServiceMonitor is created: `kubectl get servicemonitor fluentd -n fluentd`
2. Verify Prometheus is scraping Fluentd targets in the Prometheus UI
3. Confirm fluentd dashboards have been automatically imported into Grafana.