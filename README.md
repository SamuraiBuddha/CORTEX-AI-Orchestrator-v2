# 🧠 CORTEX - Collaborative Orchestration Runtime for Task EXecution

CORTEX transforms Claude into a multi-agent AI conductor orchestrating specialized delegates across distributed computing resources using n8n workflows, leveraging your existing Terramaster NAS infrastructure.

## 🎯 Vision

Create an intelligent orchestration system that:
- Coordinates multiple AI agents for complex task execution
- Utilizes existing Docker services on your Terramaster NAS
- Distributes workload across the Three Wise Men (Magi) machines
- Provides visual workflow design through n8n
- Integrates specialized AI models (Ollama, DeepSeek, Codestral)
- Monitors and optimizes performance in real-time

## 🏛️ The Three Wise Men (Magi) Architecture

### Infrastructure Overview
```
┌────────────────────────────────────────────────────────────────┐
│                    Terramaster NAS (TOS 6.0)                   │
│                16TB NVME Storage + Docker Services              │
│  PostgreSQL • Redis • Neo4j • Qdrant • Prometheus • Grafana    │
└────────────────────────────────────┬───────────────────────────┘
                                     │ 10GbE Network
             ┌───────────────────────┴───────────────────────────┐
             │                                                   │
    ┌────────┴────────────────┐         ┌───────────────────────┴─────────────┐
    │   Melchior (Gold)      │         │ Balthasar (Frankincense)            │
    │  CAD/3D Processing     │         │    AI Model Host                     │
    │  RTX 3090, 64GB RAM    │         │ RTX A5000, 128GB RAM                 │
    └────────────────────────┘         └──────────────────────────────────────┘
                                     │
                        ┌────────────┴────────────┐
                        │   Caspar (Myrrh)       │
                        │ Code/Data Processing   │
                        │  RTX A4000, 128GB      │
                        └─────────────────────────┘
```

### The Gifts They Bring:
- **Melchior (Gold)**: Enduring technical excellence in CAD/3D
- **Balthasar (Frankincense)**: Transforming data into AI insights
- **Caspar (Myrrh)**: Preserving and transforming code/processes

## 📋 Architecture Clarification

### Two Complementary Systems

1. **MCP (Model Context Protocol) - For Claude's Direct Access**
   - Hosted by [CORTEX-MCP-Extensions](https://github.com/SamuraiBuddha/CORTEX-MCP-Extensions)
   - Provides tools Claude can use directly through Docker Desktop
   - Enables Claude to interact with databases, monitoring, and services
   - Limited to single-machine context (Claude Desktop limitation)

2. **n8n Orchestration - For Multi-Machine Coordination**
   - This repository (CORTEX-AI-Orchestrator-v2)
   - Bypasses MCP single-machine limitations
   - Coordinates workflows across all three Magi machines
   - Visual workflow design and monitoring
   - Handles complex, distributed AI pipelines

### Service Deployment Model

#### 🏗️ Production Deployment (What Actually Runs Where)

**Terramaster NAS Services** (Already Running):
- PostgreSQL, Redis, Neo4j, Qdrant (Databases)
- Prometheus, Grafana, Loki (Monitoring Stack)
- MCP Servers (from CORTEX-MCP-Extensions)

**Native Windows Services**:
- InfluxDB (port 8086) - Time series metrics

**Magi Machine Services**:
- n8n (workflow orchestration) - Runs on each Magi
- Flowise (AI flow builder) - As needed
- Ollama/LocalAI - Native GPU access on Balthasar
- Development tools - Native on each machine

#### 🔧 Development Setup (docker-compose.yml)

The `docker-compose.yml` includes ALL services for easy development/testing:
- Use as-is for local development
- For production, use `docker-compose.override.yml` to point to NAS services
- See `docker-compose.override.example.yml` for configuration examples

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose on Magi machines
- Terramaster NAS with running services
- 10GbE network connecting all systems
- Windows InfluxDB instance (running natively)

### Installation

1. Clone the repository on your primary Magi machine:
```bash
git clone https://github.com/SamuraiBuddha/CORTEX-AI-Orchestrator-v2.git
cd CORTEX-AI-Orchestrator-v2
```

2. Configure for production use:
```bash
cp .env.example .env
# Edit .env with:
# - NAS_IP (your Terramaster IP)
# - MACHINE_ID (melchior-cad, balthasar-ai, or caspar-code)
# - Database passwords matching your NAS setup
# - INFLUX_TOKEN from your Windows InfluxDB

# For production deployment pointing to NAS services:
cp docker-compose.override.example.yml docker-compose.override.yml
# Edit to point to your NAS IP addresses
```

3. Start CORTEX services:
```bash
# Only start application services (databases are on NAS)
docker-compose up -d n8n
docker-compose up -d flowise  # If needed
```

4. Access services:
- n8n: http://localhost:5678
- Grafana: http://terramaster.local:3000
- Neo4j: http://terramaster.local:7474
- InfluxDB: http://localhost:8086 (Windows native)

## 🖥️ Multi-Machine Deployment

Deploy services based on the Magi machine roles:

### On Melchior (CAD/3D Processing)
```bash
export MACHINE_ID=melchior-cad
docker-compose up -d n8n  # CAD workflow orchestration
```

### On Balthasar (AI Model Host)
```bash
export MACHINE_ID=balthasar-ai
# Run Ollama, LocalAI natively for maximum GPU performance
# They'll connect to NAS databases for persistence
```

### On Caspar (Code/Data Processing)
```bash
export MACHINE_ID=caspar-code
docker-compose up -d n8n flowise  # Code generation & data flows
```

## 📊 Workflow Pipelines

CORTEX includes specialized pipelines:
- **Master Dispatcher**: Routes tasks to appropriate pipelines
- **CAD Pipeline**: Handles CAD/3D modeling tasks (Melchior)
- **Code Pipeline**: Software development automation (Caspar)
- **AI Pipeline**: Model inference and training (Balthasar)
- **Research Pipeline**: Academic/technical research
- **Data Pipeline**: Data processing and analysis

## 🔧 Configuration

See [NAS Integration Guide](docs/NAS_INTEGRATION.md) for detailed setup.

### Key Configuration Files
- `.env`: Environment variables and secrets
- `docker-compose.yml`: Full service definitions (dev/test)
- `docker-compose.override.yml`: Production overrides pointing to NAS
- `docker-compose.override.example.yml`: Example production config

### Network Configuration
```bash
# Add to hosts file if needed
192.168.1.100 terramaster.local
192.168.1.101 melchior.local
192.168.1.102 balthasar.local
192.168.1.103 caspar.local
```

## 🔗 Repository Relationships

1. **[CORTEX-AI-Orchestrator-v2](https://github.com/SamuraiBuddha/CORTEX-AI-Orchestrator-v2)** (This Repo)
   - n8n-based orchestration across multiple machines
   - Workflow pipelines and automation
   - Production deployment configurations

2. **[CORTEX-MCP-Extensions](https://github.com/SamuraiBuddha/CORTEX-MCP-Extensions)**
   - MCP servers for Claude's direct access
   - Deployed to Terramaster NAS
   - Single-machine Claude integrations

3. **[Magi-Windows-Deployments](https://github.com/SamuraiBuddha/Magi-Windows-Deployments)**
   - Windows 11 Pro deployment configs
   - Machine-specific software stacks
   - Native service configurations

4. **[homelab-infrastructure](https://github.com/SamuraiBuddha/homelab-infrastructure)**
   - Hardware specifications and benchmarks
   - Network topology and configuration
   - Infrastructure as Code

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - Detailed system design
- [NAS Integration Guide](docs/NAS_INTEGRATION.md) - Using Terramaster services
- [MCP vs n8n Guide](docs/MCP_VS_N8N.md) - When to use which system
- [Development Session 1](docs/DEVELOPMENT_SESSION_1.MD) - Initial development notes
- [Project Structure](docs/PROJECT_STRUCTURE.md) - Directory layout
- [API Documentation](docs/API.md) - Service endpoints
- [Workflow Guide](docs/WORKFLOWS.md) - n8n workflow creation

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- Inspired by coleam00's [Archon](https://github.com/coleam00/archon-ai) project
- Built on [n8n](https://n8n.io/) workflow automation
- Leverages the [self-hosted-ai-starter-kit](https://github.com/coleam00/self-hosted-ai-starter-kit)
- Powered by the Three Wise Men naming from [Magi-Windows-Deployments](https://github.com/SamuraiBuddha/Magi-Windows-Deployments)

## 🚧 Current Status

- [x] Repository initialized
- [x] Architecture documented
- [x] NAS integration configured
- [x] Magi naming scheme implemented
- [x] InfluxDB native Windows support added
- [ ] Core workflows implemented
- [ ] Multi-machine deployment tested
- [ ] Production ready

---

**Created by**: Jordan Paul Ehrig (SamuraiBuddha)  
**Company**: Ehrig BIM & IT Consultation, Inc.
