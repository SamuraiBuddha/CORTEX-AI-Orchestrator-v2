# NAS Integration Guide for CORTEX

This guide explains how CORTEX integrates with your Terramaster NAS infrastructure.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Terramaster NAS (TOS 6.0)                 │
│                        16TB NVME Storage                      │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   PostgreSQL    │  │      Redis      │  │    Neo4j     │ │
│  │   Port: 5432    │  │   Port: 6379    │  │ Ports: 7474, │ │
│  └─────────────────┘  └─────────────────┘  │     7687     │ │
│                                             └──────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │     Qdrant      │  │   Prometheus    │  │   Grafana    │ │
│  │   Port: 6333    │  │   Port: 9090    │  │  Port: 3000  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │      Loki       │  │    InfluxDB*    │  │  MCP Servers │ │
│  │   Port: 3100    │  │   Port: 8086    │  │   (Various)  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└───────────────────────────────┬─────────────────────────────┘
                                │ 10GbE Network
                ┌───────────────┴────────────────┐
                │                                │
    ┌───────────┴──────────┐        ┌───────────┴──────────┐
    │   Melchior (Gold)    │        │ Balthazar (Frankincense)│
    │  CAD/3D Processing   │        │    AI Model Host       │
    │  RTX 3090, 64GB RAM  │        │ RTX A5000, 128GB RAM   │
    └──────────────────────┘        └──────────────────────┘
                                │
                    ┌───────────┴──────────┐
                    │   Caspar (Myrrh)     │
                    │  Code/Data Processing│
                    │  RTX A4000, 128GB    │
                    └──────────────────────┘

* InfluxDB is running natively on Windows (not in Docker)
```

## Using Existing NAS Services

CORTEX is designed to use the services already running on your Terramaster NAS. The `docker-compose.override.yml` file ensures we don't duplicate these services.

### Service Connections

All services connect to the NAS using the hostname `terramaster.local` or the IP address configured in your `.env` file.

| Service | NAS Host | Port | Purpose |
|---------|----------|------|---------|
| PostgreSQL | terramaster.local | 5432 | Primary database |
| Redis | terramaster.local | 6379 | Queue and caching |
| Neo4j | terramaster.local | 7474/7687 | Knowledge graph |
| Qdrant | terramaster.local | 6333 | Vector database |
| Prometheus | terramaster.local | 9090 | Metrics collection |
| Grafana | terramaster.local | 3000 | Monitoring dashboards |
| Loki | terramaster.local | 3100 | Log aggregation |
| InfluxDB | host.docker.internal | 8086 | Time series (Windows native) |

## Deployment Steps

### 1. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and set:
# - NAS_IP to your Terramaster IP (e.g., 192.168.1.100)
# - Database passwords to match your NAS setup
# - MACHINE_ID to the appropriate Magi machine
# - INFLUX_TOKEN from your Windows InfluxDB instance
```

### 2. Start CORTEX Services

Since all databases are on the NAS, you only need to start application services:

```bash
# Start n8n (orchestration engine)
docker-compose up -d n8n

# Start Flowise (if needed for AI flows)
docker-compose up -d flowise

# Start Open WebUI (if needed for model interface)
docker-compose up -d open-webui
```

### 3. Verify Connections

Check that services can connect to the NAS:

```bash
# Test PostgreSQL connection
docker-compose exec n8n psql -h terramaster.local -U postgres -d cortex_db -c "SELECT 1"

# Test Redis connection
docker-compose exec n8n redis-cli -h terramaster.local ping

# Check n8n logs
docker-compose logs n8n
```

### 4. Machine-Specific Deployment

Deploy services to the appropriate Magi machine based on workload:

#### On Melchior (CAD/3D Processing)
```bash
export MACHINE_ID=melchior-cad
docker-compose up -d n8n  # For CAD workflow orchestration
```

#### On Balthazar (AI Model Host)
```bash
export MACHINE_ID=balthazar-ai
# Run Ollama, LocalAI, or other model servers natively
# They'll use NAS databases for persistence
```

#### On Caspar (Code/Data Processing)
```bash
export MACHINE_ID=caspar-code
docker-compose up -d n8n  # For code generation workflows
docker-compose up -d flowise  # For data processing flows
```

## Network Configuration

### Firewall Rules

Ensure Windows Firewall allows connections:

```powershell
# Allow Docker to access InfluxDB
New-NetFirewallRule -DisplayName "InfluxDB for Docker" -Direction Inbound -Protocol TCP -LocalPort 8086 -Action Allow

# Allow connections from NAS network
New-NetFirewallRule -DisplayName "CORTEX from NAS" -Direction Inbound -RemoteAddress 192.168.1.0/24 -Action Allow
```

### DNS Resolution

Add to your hosts file if DNS doesn't resolve:

```
# C:\Windows\System32\drivers\etc\hosts
192.168.1.100 terramaster.local
192.168.1.101 melchior.local
192.168.1.102 balthazar.local
192.168.1.103 caspar.local
```

## MCP Integration

The MCP servers running on the NAS can be accessed by all Magi machines:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://terramaster.local/cortex_db"]
    },
    "redis": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-redis"],
      "env": {
        "REDIS_HOST": "terramaster.local"
      }
    },
    "neo4j": {
      "command": "npx",
      "args": ["-y", "mcp-neo4j"],
      "env": {
        "NEO4J_URI": "bolt://terramaster.local:7687",
        "NEO4J_USERNAME": "neo4j",
        "NEO4J_PASSWORD": "${NEO4J_PASSWORD}"
      }
    }
  }
}
```

## Monitoring

Access monitoring dashboards:

- **Grafana**: http://terramaster.local:3000
- **Prometheus**: http://terramaster.local:9090
- **InfluxDB**: http://localhost:8086 (Windows native)

## Troubleshooting

### Connection Issues

```bash
# Test NAS connectivity
ping terramaster.local

# Check Docker network
docker network ls
docker network inspect self-hosted-ai-starter-kit_demo

# Verify service health
curl http://terramaster.local:5678/healthz  # n8n
curl http://terramaster.local:6333/health  # Qdrant
```

### Service Discovery

If services can't find each other:

1. Check `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts`
2. Verify Docker's extra_hosts configuration
3. Ensure all services are on the same Docker network

### Performance Optimization

- Use the 10GbE network for all inter-machine communication
- Place high-throughput services (like n8n) on the same machine as their primary workload
- Use Redis on the NAS for shared caching across all Magi machines

## Best Practices

1. **Don't Duplicate Services**: Use NAS services instead of running local copies
2. **Centralized Storage**: Keep all persistent data on the NAS
3. **Distributed Processing**: Run compute-intensive tasks on the appropriate Magi machine
4. **Unified Monitoring**: Use Grafana on the NAS to monitor all systems
5. **Backup Strategy**: Leverage NAS RAID for data protection
