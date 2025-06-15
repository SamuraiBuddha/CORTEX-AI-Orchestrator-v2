# 🧠 CORTEX - Collaborative Orchestration Runtime for Task EXecution

CORTEX transforms Claude into a multi-agent AI conductor orchestrating specialized delegates across distributed computing resources using n8n workflows.

## 🎯 Vision

Create an intelligent orchestration system that:
- Coordinates multiple AI agents for complex task execution
- Distributes workload across multiple high-performance machines
- Provides visual workflow design through n8n
- Integrates specialized AI models (Ollama, DeepSeek, Codestral)
- Monitors and optimizes performance in real-time

## 🏗️ Architecture

CORTEX uses n8n as its core orchestration engine, providing:
- **Visual Workflow Design**: No-code orchestration
- **Distributed Processing**: Load balance across 3 machines
- **Agent Delegation**: Route to specialized models
- **Error Handling**: Retry logic and fallbacks
- **Caching Layer**: Redis for performance
- **Monitoring**: Grafana/Prometheus integration
- **Flexibility**: Mix cloud and local resources

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- 10GbE network (for multi-machine setup)
- Minimum 32GB RAM per machine

### Installation

1. Clone the repository:
```bash
git clone https://github.com/SamuraiBuddha/CORTEX-AI-Orchestrator-v2.git
cd CORTEX-AI-Orchestrator-v2
```

2. Run the setup script:
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

3. Configure environment:
```bash
# Edit .env file with your secure values
nano .env
```

4. Start CORTEX:
```bash
docker-compose up -d
```

5. Access services:
- n8n: http://localhost:5678
- Grafana: http://localhost:3000
- Neo4j: http://localhost:7474
- Prometheus: http://localhost:9090

## 📦 Stack Components

### Core Services
- **PostgreSQL**: Central database
- **n8n**: Workflow orchestration
- **Redis**: Caching and message queue
- **Neo4j**: Knowledge graph database
- **Qdrant**: Vector database for embeddings

### AI Integration
- **Flowise**: Visual AI flow builder
- **Open WebUI**: Model interface (optional)
- Support for Ollama, DeepSeek, Codestral

### Monitoring Stack
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Loki**: Log aggregation
- **InfluxDB**: Time series data
- **cAdvisor**: Container monitoring
- **Node Exporter**: System metrics

## 🖥️ Multi-Machine Deployment

CORTEX is designed to run across three powerful machines:

### Machine Configuration
1. **Machine 1**: i9 11th Gen, 64GB RAM, RTX 3090
2. **Machine 2**: i9 11th Gen, 128GB RAM, RTX A5000
3. **Machine 3**: Ryzen 9 5950X, 128GB RAM, RTX A4000

### Deployment Steps
1. Set `MACHINE_ID` in `.env` on each machine
2. Configure resource limits based on hardware
3. Ensure network connectivity between machines
4. Use deployment scripts for targeted setup

## 📊 Workflow Pipelines

CORTEX includes specialized pipelines:
- **Master Dispatcher**: Routes tasks to appropriate pipelines
- **CAD Pipeline**: Handles CAD/3D modeling tasks
- **Code Pipeline**: Software development automation
- **Research Pipeline**: Academic/technical research
- **Data Pipeline**: Data processing and analysis

## 🔧 Configuration

### Environment Variables
Key variables in `.env`:
- `POSTGRES_PASSWORD`: Database password
- `N8N_ENCRYPTION_KEY`: n8n encryption key
- `MACHINE_ID`: Identifier for multi-machine setup
- `GRAFANA_PASSWORD`: Monitoring dashboard password

### Resource Limits
Adjust in `docker-compose.yml` based on your hardware:
- PostgreSQL connections
- Redis memory limits
- Neo4j heap sizes

## 📚 Documentation

- [Development Session 1](docs/DEVELOPMENT_SESSION_1.MD) - Initial development notes
- [Project Structure](docs/PROJECT_STRUCTURE.md) - Directory layout
- [API Documentation](docs/API.md) - Service endpoints
- [Workflow Guide](docs/WORKFLOWS.md) - n8n workflow creation

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- Inspired by coleam00's [Archon](https://github.com/coleam00/archon-ai) project
- Built on [n8n](https://n8n.io/) workflow automation
- Leverages the [self-hosted-ai-starter-kit](https://github.com/coleam00/self-hosted-ai-starter-kit)

## 🚧 Current Status

- [x] Repository initialized
- [x] Architecture documented
- [x] Docker stack configured
- [ ] Core workflows implemented
- [ ] Multi-machine deployment tested
- [ ] Production ready

---

**Created by**: Jordan Paul Ehrig (SamuraiBuddha)  
**Company**: Ehrig BIM & IT Consultation, Inc.