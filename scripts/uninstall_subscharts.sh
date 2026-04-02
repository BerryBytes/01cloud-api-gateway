#!/bin/bash

set -e

echo "Uninstalling Krakend..."
helm uninstall krakend -n krakend || echo "Krakend not found"
kubectl delete namespace krakend --ignore-not-found=true

echo "Uninstalling Alloy..."
helm uninstall alloy -n loki || echo "Alloy not found"
kubectl delete configmap alloy-config -n loki --ignore-not-found=true

echo "Uninstalling Prometheus..."
helm uninstall prometheus -n zerone-monitoring || echo "Prometheus not found"
kubectl delete namespace zerone-monitoring --ignore-not-found=true

echo "Uninstalling Loki..."
helm uninstall loki -n loki || echo "Loki not found"

echo "Uninstalling Grafana..."
helm uninstall grafana -n loki || echo "Grafana not found"
kubectl delete -f ./../charts/grafana/grafana-ingress.yaml --ignore-not-found=true

echo "Cleaning up 'loki' namespace if empty..."
kubectl delete namespace loki --ignore-not-found=true

echo "Uninstallation completed successfully!"
