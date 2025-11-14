# Platform Services
This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose
- Centralized platform for developing and testing application services
- Provides observability, configuration, authentication, API gateway, and other infrastructure components

## Project Structure
```
project-root
├── platform                           # This repo
│   ├── bootstrap                      # Scripts to initialize platform and clone services
│   │   ├── .tools
│   │   ├── /scripts/*
│   │   └── main.sh / main.ps1         # Entry point for bootstrap
│   │ 
│   ├── deployment
│   │   ├── helm                       # TBD
│   │   └── docker-compose             # Local dev environment
│   │       ├── observability          # Observability configuration 
│   │       └── docker-compose.yml
│   │
│   ├── docs
│   │   ├── adr                        # TBD
│   │   └── diagrams                   # TBD
│   │
│   ├── infrastructure                 # TBD
│   ├── platform-bom                   # Dependency management
│   └── platform-config.yaml           # List of bootstrapped services
│   
├── bounded-contexts                   # Business services
│   ├── <some-service>
│   │   ├── src
│   │   ├── Dockerfile 
│   │   └── docker-compose.yml
│   └── ...
└── ...
```

## Bootstrap
Initializes platform structure and clones service repositories.

**What it does:**
- Creates `bounded-contexts` directories
- Clones/updates services from `platform-config.yaml`

### Usage
~~**Linux:**~~ TBD
```bash
./bootstrap/main.sh
```

**Windows:**
```powershell
./bootstrap/main.ps1
```


## Current Status
### Local Development
Use provided scripts (compose-up, compose-down) to start/stop the local development cluster.

**Deployed via Docker Compose:**
* **Observability stack**: Grafana Alloy, Grafana, Loki, Tempo, Mimir, Pyroscope (not yet configured)

### Kubernetes
Helm deployment: TBD