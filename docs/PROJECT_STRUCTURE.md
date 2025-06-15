# CORTEX Project Structure

```
CORTEX-AI-Orchestrator/
├── docker-compose.yml              # Main orchestration file
├── .env                           # Environment variables (create from .env.example)
├── .env.example                   # Template for environment variables
├── README.md                      # Project documentation
├── LICENSE                        # MIT License
│
├── docs/                          # Documentation
│   └── DEVELOPMENT_SESSION_1.MD   # Initial development notes
│
├── n8n/                           # n8n workflow configurations
│   ├── backup/                    # Workflow backups
│   ├── custom-nodes/              # Custom n8n nodes
│   └── workflows/                 # Exported workflows
│       ├── master-dispatcher.json
│       ├── cad-pipeline.json
│       ├── code-pipeline.json
│       ├── research-pipeline.json
│       └── data-pipeline.json
│
├── shared/                        # Shared data between services
│   ├── models/                    # AI model files
│   ├── datasets/                  # Training/reference data
│   └── cache/                     # Shared cache directory
│
├── monitoring/                    # Monitoring configurations
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── rules/
│   │       ├── alerts.yml
│   │       └── recording.yml
│   ├── grafana/
│   │   ├── provisioning/
│   │   │   ├── dashboards/
│   │   │   └── datasources/
│   │   └── dashboards/
│   │       ├── cortex-overview.json
│   │       ├── n8n-metrics.json
│   │       └── system-metrics.json
│   ├── loki/
│   │   └── loki-config.yaml
│   └── promtail/
│       └── promtail-config.yaml
│
├── postgres/                      # PostgreSQL configurations
│   └── init-scripts/              # Database initialization
│       └── 01-create-databases.sql
│
├── qdrant/                        # Vector database configs
│   └── config/
│       └── config.yaml
│
├── scripts/                       # Utility scripts
│   ├── setup.sh                   # Initial setup script
│   ├── backup.sh                  # Backup script
│   ├── deploy-agent.sh            # Deploy to specific machine
│   └── health-check.sh            # System health check
│
├── agents/                        # AI Agent configurations
│   ├── ollama/                    # Ollama model configs
│   ├── deepseek/                  # DeepSeek configs
│   └── codestral/                 # Codestral configs
│
└── pipelines/                     # Pipeline templates
    ├── templates/                 # Reusable pipeline components
    └── examples/                  # Example implementations
```

## Key Directories Explained

### `/n8n/workflows/`
Contains the core workflow definitions:
- **master-dispatcher.json**: Routes tasks to appropriate pipelines
- **cad-pipeline.json**: Handles CAD/3D modeling tasks
- **code-pipeline.json**: Software development automation
- **research-pipeline.json**: Academic/technical research
- **data-pipeline.json**: Data processing and analysis

### `/shared/`
Mounted to all containers for data exchange:
- Models and datasets accessible by all services
- Shared cache for performance optimization
- Inter-service communication files

### `/monitoring/`
Complete observability stack configuration:
- Prometheus for metrics collection
- Grafana dashboards for visualization
- Loki for log aggregation
- Alert rules and recording rules

### `/scripts/`
Automation and management tools:
- Setup script for initial configuration
- Backup utilities for data persistence
- Deployment scripts for multi-machine setup
- Health monitoring scripts

### `/agents/`
AI model configurations for different specialized tasks:
- Ollama for local LLM deployment
- DeepSeek for code analysis
- Codestral for advanced coding tasks

## Getting Started

1. Copy `.env.example` to `.env` and configure
2. Run `./scripts/setup.sh` to initialize
3. Start services: `docker-compose up -d`
4. Access n8n at http://localhost:5678
5. Import workflows from `/n8n/workflows/`
6. Access Grafana at http://localhost:3000

## Multi-Machine Deployment

For distributed setup across your 3 machines:
1. Set `MACHINE_ID` in `.env` (machine1, machine2, machine3)
2. Configure resource limits based on hardware
3. Use `./scripts/deploy-agent.sh` for targeted deployment
4. Ensure 10GbE network connectivity between machines