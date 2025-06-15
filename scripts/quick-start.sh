#!/bin/bash
# CORTEX Quick Start Commands
# Run these commands in sequence to get CORTEX up and running

echo "🧠 CORTEX Quick Start Sequence"
echo "=============================="

# Step 1: Environment Setup
echo -e "\n📋 Step 1: Copy and configure environment file"
echo "cp .env.example .env"
echo "# Edit .env and add your tokens/passwords"

# Step 2: Create directories
echo -e "\n📁 Step 2: Create required directories"
echo "mkdir -p data/{postgres,neo4j,influxdb,grafana,prometheus,loki}"
echo "mkdir -p logs workflows/shared monitoring/grafana/dashboards"

# Step 3: Start core databases
echo -e "\n🗄️ Step 3: Start core databases"
echo "docker-compose up -d postgres redis"
echo "# Wait 30 seconds for initialization"
echo "sleep 30"

# Step 4: Start graph and vector stores  
echo -e "\n🔗 Step 4: Start graph and vector databases"
echo "docker-compose up -d neo4j qdrant"
echo "# Wait for services to be ready"
echo "sleep 30"

# Step 5: Start n8n
echo -e "\n🔄 Step 5: Start n8n orchestrator"
echo "docker-compose up -d n8n"
echo "# Access n8n at http://localhost:5678"

# Step 6: Start monitoring (optional)
echo -e "\n📊 Step 6: Start monitoring stack (optional)"
echo "docker-compose up -d prometheus grafana loki"
echo "# Access Grafana at http://localhost:3000 (admin/admin)"

# Step 7: Verify all services
echo -e "\n✅ Step 7: Check service status"
echo "docker-compose ps"
echo "docker-compose logs --tail=50"

echo -e "\n🚀 Quick Links:"
echo "- n8n: http://localhost:5678"
echo "- Grafana: http://localhost:3000" 
echo "- Neo4j: http://localhost:7474"
echo "- InfluxDB: http://localhost:8086"
echo "- Prometheus: http://localhost:9090"

echo -e "\n📝 Next Steps:"
echo "1. Get InfluxDB token from http://localhost:8086"
echo "2. Update .env with the token"
echo "3. Configure n8n credentials"
echo "4. Import master dispatcher workflow"
echo "5. Test service connectivity"