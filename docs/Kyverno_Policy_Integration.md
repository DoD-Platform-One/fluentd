#  How to Enable Kyverno Policy Integration for Fluentd

This guide explains how to ensure Kyverno Policy integration with Big Bang for Fluentd.

**NOTE:** This guide assumes you will be using the Big Bang [Kyverno Policies Chart](https://repo1.dso.mil/big-bang/product/packages/kyverno-policies)

## 1. Enable Exceptions for Kyverno Policy

- If Kyverno Policies are enabled, the following Kyverno Policies will require exceptions to deploy Fluentd Daemonset on Big Bang:
  - add-default-securitycontext
  - require-non-root-user:
  - restrict-host-path-mount:
  - restrict-host-path-write:
  - restrict-volume-types:


```yaml
kyvernoPolicies:
  enabled: true 
  values:
    policies:
      add-default-securitycontext:
        exclude:
          any:
          - resources:
              namespaces:
              - fluentd
              names:
              - fluentd*
      require-non-root-group:
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
```

## 2. Verification

After applying this configuration:

1. Check that the Fluentd Daemonset are running and in healthy state