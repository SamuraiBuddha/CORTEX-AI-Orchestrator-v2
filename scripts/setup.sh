#!/bin/bash
# CORTEX AI Orchestrator Setup Script
# This script initializes the CORTEX environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${BLUE}"
cat << "EOF"
   _____ ____  _____ _______ ________   __
  / ___// __ \/ ___//_  __// ____/ |  / /
 / /   / / / / /_    / /  / /_   | | / / 
/ /___/ /_/ / / /   / /  / __/   | |/ /  
\____/\____/_/     /_/  /_/      |___/   
                                          
Collaborative Orchestration Runtime for Task EXecution
EOF
echo -e "${NC}"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_info "Creating directory structure..."

# Create necessary directories
directories=(
    "n8n/backup"
    "n8n/custom-nodes"
    "n8n/workflows"
    "shared/models"
    "shared/datasets"
    "shared/cache"
    "monitoring/prometheus/rules"
    "monitoring/grafana/provisioning/dashboards"
    "monitoring/grafana/provisioning/datasources"
    "monitoring/grafana/dashboards"
    "monitoring/loki"
    "monitoring/promtail"
    "postgres/init-scripts"
    "qdrant/config"
    "scripts"
    "agents/ollama"
    "agents/deepseek"
    "agents/codestral"
    "pipelines/templates"
    "pipelines/examples"
)

for dir in "${directories[@]}"; do
    mkdir -p "$dir"
    print_success "Created $dir"
done

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        print_warning ".env file created from .env.example. Please update it with your secure values!"
    else
        print_error ".env.example not found. Creating basic .env file..."
        cat > .env << 'EOL'
# CORTEX Environment Configuration
POSTGRES_PASSWORD=ChangeMe123!
NEO4J_PASSWORD=ChangeMe123!
N8N_ENCRYPTION_KEY=$(openssl rand -hex 16)
N8N_JWT_SECRET=$(openssl rand -hex 16)
INFLUX_PASSWORD=ChangeMe123!
INFLUX_TOKEN=$(openssl rand -hex 32)
GRAFANA_PASSWORD=ChangeMe123!
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=ChangeMe123!
WEBUI_SECRET_KEY=$(openssl rand -hex 16)
EOL
        print_warning "Basic .env file created. Please update it with secure values!"
    fi
fi

# Create PostgreSQL initialization script
print_info "Creating PostgreSQL initialization script..."
cat > postgres/init-scripts/01-create-databases.sql << 'EOL'
-- Create databases for CORTEX services
CREATE DATABASE cortex_db;
CREATE DATABASE n8n;
CREATE DATABASE flowise;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE cortex_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE n8n TO postgres;
GRANT ALL PRIVILEGES ON DATABASE flowise TO postgres;
EOL

# Create Loki configuration
print_info "Creating Loki configuration..."
cat > monitoring/loki/loki-config.yaml << 'EOL'
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093

analytics:
  reporting_enabled: false
EOL

# Create Promtail configuration
print_info "Creating Promtail configuration..."
cat > monitoring/promtail/promtail-config.yaml << 'EOL'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: containers
    static_configs:
      - targets:
          - localhost
        labels:
          job: containerlogs
          __path__: /var/lib/docker/containers/*/*log
    
    pipeline_stages:
      - json:
          expressions:
            output: log
            stream: stream
            attrs:
      - json:
          expressions:
            tag:
          source: attrs
      - regex:
          expression: (?P<image_name>(?:[^|]*[^|])).(?P<container_name>(?:[^|]*[^|])).(?P<image_id>(?:[^|]*[^|])).(?P<container_id>(?:[^|]*[^|]))
          source: tag
      - timestamp:
          format: RFC3339Nano
          source: time
      - labels:
          stream:
          image_name:
          container_name:
          image_id:
          container_id:
      - output:
          source: output
EOL

# Create Grafana datasources provisioning
print_info "Creating Grafana datasources..."
cat > monitoring/grafana/provisioning/datasources/datasources.yaml << 'EOL'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    
  - name: InfluxDB
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    jsonData:
      version: Flux
      organization: cortex
      defaultBucket: metrics
      tlsSkipVerify: true
    secureJsonData:
      token: ${INFLUX_TOKEN}
EOL

# Create Grafana dashboards provisioning
print_info "Creating Grafana dashboards provisioning..."
cat > monitoring/grafana/provisioning/dashboards/dashboards.yaml << 'EOL'
apiVersion: 1

providers:
  - name: 'CORTEX Dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOL

# Create basic Prometheus rules
print_info "Creating Prometheus alert rules..."
cat > monitoring/prometheus/rules/alerts.yml << 'EOL'
groups:
  - name: cortex_alerts
    interval: 30s
    rules:
      - alert: ContainerDown
        expr: up{job="cadvisor"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "Container {{ $labels.instance }} has been down for more than 5 minutes."
      
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 90% on {{ $labels.instance }}"
      
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% on {{ $labels.instance }}"
EOL

# Create a sample n8n workflow
print_info "Creating sample n8n workflow..."
cat > n8n/workflows/master-dispatcher.json << 'EOL'
{
  "name": "CORTEX Master Dispatcher",
  "nodes": [
    {
      "parameters": {},
      "id": "webhook",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "webhookId": "cortex-dispatcher"
    }
  ],
  "connections": {},
  "active": false,
  "settings": {},
  "id": "cortex-master-001"
}
EOL

# Create health check script
print_info "Creating health check script..."
cat > scripts/health-check.sh << 'EOL'
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
EOL

chmod +x scripts/health-check.sh

# Final setup steps
print_info "Pulling Docker images..."
docker-compose pull

print_success "CORTEX setup completed!"
echo ""
print_info "Next steps:"
echo "1. Update the .env file with secure passwords"
echo "2. Start CORTEX: docker-compose up -d"
echo "3. Access n8n at http://localhost:5678"
echo "4. Access Grafana at http://localhost:3000 (admin/your-password)"
echo "5. Import workflows from n8n/workflows/"
echo ""
print_warning "Remember to configure your AI models and update passwords!"