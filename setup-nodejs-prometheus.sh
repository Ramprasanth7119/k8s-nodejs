#!/bin/bash

# Exit immediately on any error
set -e

echo "🔧 Patching nodejs-service to target port 3000..."
kubectl patch svc nodejs-service -p '{
  "spec": {
    "ports": [{
      "port": 8080,
      "targetPort": 3000,
      "name": "http"
    }]
  }
}'

echo "🏷️ Adding label 'app=nodejs' to nodejs-service..."
kubectl label svc nodejs-service app=nodejs --overwrite

echo "📝 Creating ServiceMonitor for Prometheus..."
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nodejs-monitor
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: nodejs
  namespaceSelector:
    matchNames:
      - default
  endpoints:
    - port: http
      path: /metrics
      interval: 15s
EOF

echo "✅ Done. Verify the target appears in Prometheus UI → Status → Targets."
