# Krakend Deployment and Configuration Process

## Deployment Process

### Step 1: Add Helm Chart
Ensure the Krakend Helm chart is included in the repository under `charts/krakend`.

### Step 2: Install Krakend
Use the following command to install Krakend:
```
helm install krakend charts/krakend -n krakend --create-namespace
```

### Step 3: Verify Deployment
Check the status of the Krakend pods:
```
kubectl get pods -n krakend
```

### Step 4: Expose Metrics
Ensure the metrics endpoint is accessible by port-forwarding or exposing it via a Kubernetes Service:
```
kubectl port-forward <krakend-pod-name> 9091:9091 -n krakend
```

---

## Logging and Metrics Configuration

### Logging Configuration
Enable logging by defining the `telemetry/logging` section in the configuration:
```json
"telemetry/logging": {
  "level": "DEBUG",
  "prefix": "[KRAKEND]",
  "syslog": false,
  "stdout": true,
  "access_enable": "true",
  "access_log_format": "json",
  "format": "json"
}
```

### Metrics Configuration
Expose metrics using the `telemetry/opentelemetry` section:
```json
"telemetry/opentelemetry": {
  "service_name": "krakend_prometheus_service",
  "metric_reporting_period": 1,
  "exporters": {
    "prometheus": [
      {
        "name": "local_prometheus",
        "port": 9091,
        "process_metrics": true,
        "go_metrics": true
      }
    ]
  }
}
```

---

### Step 5: Setuping the Prometheus
Use the following command to install Prometheus:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --version 27.20.0 -n zerone-monitoring --create-namespace
```
- Update the "prometheus-operator-server" configmap to scrape the metrics from krakend to Prometheus 

```
    scrape_configs:
    - job_name: prometheus
      static_configs:
      - targets:
        - localhost:9090
    - job_name: krakend
      static_configs:
      - targets:
        - krakend.krakend.svc.cluster.local:9091
```
- Restart the prometheus server pod to load the changes in the configmap 

```
- kubectl port-forward prometheus-operator-server 9090:9090 -n zerone-monitoring 
- Check the target state in the prometheus UI for the status -> targets wheather krakend endpoints state is  up/down.
```


### Step 6: Setuping the Grafana 

Use the following command to install Krakend:
```
helm install krakend charts/krakend -n krakend --create-namespace
```
#### Adding the Prometheus and Loki data sourcs in the grafana 

```
i. Prometheus 
- Navigate to data source -> Add new connection 
-  Add the Prometheus server URL : "http://prometheus-operator-server.zerone-monitoring.svc.cluster.local"
- Test and save the connection 
- To visualize the scrape metrics 
- Add KrakenD - OpenTelemetry + Prometheus dashboard from the reference link and choose the prometheus data source 
- https://grafana.com/grafana/dashboards/20651-krakend-opentelemetry-prometheus/
```

```
ii. Loki 
- Navigate to data source -> Add new connection 
-  Add the Loki server URL : "http://loki-gateway.loki.svc.cluster.local"
- Add the Authentication  if using mircoservice mode 
- Add the X-Scope-OrgID in HTTP Headers 
- Test and save the connection 
- To visualize the logs 
- Add Loki dashboard from the reference link and choose the prometheus and loki data source
- https://grafana.com/grafana/dashboards/13186-loki-dashboard/
```

### Step 7: Setuping the Loki 
Use the following command to install Loki and store the logs:
```
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki --version 6.30.1 -f charts/loki/loki-values.yaml -n loki
```

### Step 8: Setuping the Grafana-Alloy 
Use the following command to install Grafana-Alloy to export logs to Loki:
```
kubectl apply -f charts/grafana-alloy/alloy-configmap.yml
helm repo add grafana https://grafana.github.io/helm-charts
helm install alloy grafana/alloy --version 1.0.3 -f charts/grafana-alloy/alloy-values.yam -n loki
```

## Summary
This document outlines the steps to deploy Krakend and configure logging and metrics. Follow these steps to ensure a scalable and maintainable API gateway setup with visualize logs and metrics.
