#!/bin/bash
# CORTEX Health Check Script

echo "Checking CORTEX services health..."

services=("postgres" "n8n" "qdrant" "neo4j" "redis" "grafana" "prometheus" "loki")

for service in "${services[@]}"; do
    if docker-compose ps | grep -q "$service.*Up"; then
        echo "✓ $service is running"
    else
        echo "✗ $service is not running"
    fi
done

# Check connectivity
echo -e "\nChecking service endpoints..."
curl -s http://localhost:5678 > /dev/null && echo "✓ n8n is accessible" || echo "✗ n8n is not accessible"
curl -s http://localhost:3000 > /dev/null && echo "✓ Grafana is accessible" || echo "✗ Grafana is not accessible"
curl -s http://localhost:9090 > /dev/null && echo "✓ Prometheus is accessible" || echo "✗ Prometheus is not accessible"
