# Helm Charts for 01cloud API Gateway

This directory contains Helm charts for deploying the 01cloud API Gateway and its related components.

## Subcharts Overview

Below is a summary of the subcharts included in this directory:

| Subchart Name | Description                                                                 | Version   | Repository URL                                      |
|---------------|-----------------------------------------------------------------------------|-----------|----------------------------------------------------|
| **grafana**   | Helm chart for deploying Grafana, a visualization and monitoring tool.     | 9.0.0     | [Grafana Helm Charts](https://grafana.github.io/helm-charts) |
| **loki**      | Helm chart for deploying Loki, a log aggregation system.                   | 6.30.1    | [Grafana Helm Charts](https://grafana.github.io/helm-charts) |
| **prometheus**| Helm chart for deploying Prometheus, a monitoring and alerting toolkit.    | 27.20.0   | [Prometheus Helm Charts](https://prometheus-community.github.io/helm-charts) |
| **alloy**     | Helm chart for deploying Grafana Alloy, used for exporting logs to Loki.   | 1.0.3     | [Grafana Helm Charts](https://grafana.github.io/helm-charts) |
| **krakend**     | Helm chart for deploying Krakend, a fast, open-source API Gateway.   | 0.1.0     | |

## Installation Instructions

### Installing Subcharts

To install individual subcharts, use the following commands:
The installation can be done from the parent directory 01cloud-api-gateway
#### Grafana
```
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana --version 9.0.0 -f charts/grafana/grafana-values.yaml -n loki --create-namespace

kubectl apply -f charts/grafana/grafana-ingress.yaml
```

#### Loki
```
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki --version 6.30.1 -f charts/loki/loki-values.yaml -n loki
```

#### Prometheus
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --version 27.20.0 -n zerone-monitoring --create-namespace -f charts/prometheus/prometheus-values.yaml

```

#### Alloy
```
kubectl apply -f charts/grafana-alloy/alloy-configmap.yml
helm repo add grafana https://grafana.github.io/helm-charts
helm install alloy grafana/alloy -f charts/grafana-alloy/alloy-values.yaml -n loki
```

#### Krakend
```
helm install krakend charts/krakend -n krakend --create-namespace
```
