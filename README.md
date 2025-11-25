<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# fluentd

![Version: 0.5.3-bb.3](https://img.shields.io/badge/Version-0.5.3--bb.3-informational?style=flat-square) ![AppVersion: 1.19.0](https://img.shields.io/badge/AppVersion-1.19.0-informational?style=flat-square) ![Maintenance Track: bb_integrated](https://img.shields.io/badge/Maintenance_Track-bb_integrated-green?style=flat-square)

A Helm chart for Kubernetes

## Upstream References

- <https://www.fluentd.org/>
- <https://github.com/fluent/fluentd/>
- <https://github.com/fluent/fluentd-kubernetes-daemonset>

## Upstream Release Notes

- [Find upstream helm chart changelog and release notes here](https://github.com/fluent/helm-charts/releases)
- [Find upstream application changelog and release notes here](https://github.com/fluent/fluentd/releases)

## Learn More

- [Application Overview](docs/overview.md)
- [Other Documentation](docs/)

## Pre-Requisites

- Kubernetes Cluster deployed
- Kubernetes config installed in `~/.kube/config`
- Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

- Clone down the repository
- cd into directory

```bash
helm install fluentd chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| upstream.nameOverride | string | `"fluentd"` |  |
| upstream.image.repository | string | `"registry1.dso.mil/ironbank/opensource/fluentd/fluentd-kubernetes-daemonset"` |  |
| upstream.image.pullPolicy | string | `"Always"` |  |
| upstream.image.tag | string | `"1.19.0"` |  |
| upstream.imagePullSecrets[0].name | string | `"private-registry"` |  |
| upstream.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.securityContext.runAsUser | int | `0` |  |
| upstream.podSecurityPolicy.enabled | bool | `false` |  |
| upstream.service.type | string | `"ClusterIP"` |  |
| upstream.service.annotations | object | `{}` |  |
| upstream.service.ports[0].name | string | `"forwarder"` |  |
| upstream.service.ports[0].protocol | string | `"TCP"` |  |
| upstream.service.ports[0].containerPort | int | `24224` |  |
| upstream.metrics.serviceMonitor.enabled | bool | `false` |  |
| upstream.dashboards.enabled | bool | `false` |  |
| upstream.env | list | `[]` |  |
| elasticsearch.enabled | bool | `false` |  |
| elasticsearch.namespace | string | `"logging"` |  |
| elasticsearch.port | int | `9200` |  |
| elasticsearch.passwordSecret.name | string | `"logging-ek-es-elastic-user"` |  |
| elasticsearch.certSecret.name | string | `"logging-ek-es-http-certs-public"` |  |
| istio.enabled | bool | `false` |  |
| istio.istiodEnabled | bool | `true` |  |
| istio.mtls | object | `{"mode":"STRICT"}` | Default peer authentication setting |
| istio.mtls.mode | string | `"STRICT"` | STRICT = Allow only mutual TLS traffic PERMISSIVE = Allow both plain text and mutual TLS traffic |
| istio.hardened.enabled | bool | `false` |  |
| istio.hardened.outboundTrafficPolicyMode | string | `"REGISTRY_ONLY"` |  |
| istio.hardened.customServiceEntries | list | `[]` |  |
| istio.hardened.customAuthorizationPolicies | list | `[]` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.ingressLabels.app | string | `"public-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.openshift.enabled | bool | `false` |  |
| networkPolicies.loki.enabled | bool | `true` |  |
| networkPolicies.tempo.enabled | bool | `true` |  |
| networkPolicies.elasticsearch.enabled | bool | `true` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.vpcCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.additionalPolicies | list | `[]` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

