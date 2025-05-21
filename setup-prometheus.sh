#!/bin/bash

set -e

echo "📁 Creating Prometheus config..."
cat <<EOF > prometheus-config.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-metrics-app'
    static_configs:
      - targets: ['node-metrics-service.default.svc.cluster.local:80']
EOF

echo "📦 Creating ConfigMap..."
kubectl create configmap prometheus-config --from-file=prometheus.yml=prometheus-config.yaml --dry-run=client -o yaml | kubectl apply -f -

echo "🛠️ Deploying Prometheus..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  type: NodePort
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30090
  selector:
    app: prometheus
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config-volume
              mountPath: /etc/prometheus/
      volumes:
        - name: prometheus-config-volume
          configMap:
            name: prometheus-config
EOF

echo "⏳ Waiting for Prometheus pod to be ready..."
kubectl wait --for=condition=available --timeout=90s deployment/prometheus

echo "🌐 Launching Prometheus UI using minikube..."
minikube service prometheus
