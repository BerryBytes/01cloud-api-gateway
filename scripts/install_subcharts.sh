#!/bin/bash

set -e

# Add Helm repositories
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Grafana
echo "Installing Grafana..."
helm install grafana grafana/grafana -f ./../charts/grafana/grafana-values.yaml -n loki --create-namespace
kubectl apply -f ./../charts/grafana/grafana-ingress.yaml

# Install Loki
echo "Installing Loki..."
helm install loki grafana/loki -f ./../charts/loki/loki-values.yaml -n loki

# Install Prometheus
echo "Installing Prometheus..."
helm install prometheus prometheus-community/prometheus -n zerone-monitoring --create-namespace -f ./../charts/prometheus/prometheus-values.yaml

# Install Alloy
echo "Installing Alloy..."
kubectl apply -f ./../charts/grafana-alloy/alloy-configmap.yml
helm install alloy grafana/alloy -f ./../charts/grafana-alloy/alloy-values.yaml -n loki

# Install Krakend
echo "Installing Krakend..."
helm install krakend ./../charts/krakend -n krakend --create-namespace

echo "Installation completed successfully!"
