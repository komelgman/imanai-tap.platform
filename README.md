# Platform Services
This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose
- Centralized platform for developing and testing application services
- Provides observability, configuration, authentication, API gateway, and other infrastructure components

## Project Structure
```
project-root
├── platform                            # This repo
│   ├── bootstrap                       # Scripts to initialize platform and clone services
│   │   ├── .tools
│   │   ├── scripts
│   │   └── main.ps1                    # Entry point for bootstrap
│   │ 
│   ├── deployment
│   │   ├── helm                        # TBD
│   │   └── docker-compose              # Local dev environment
│   │       ├── observability           # Observability configuration 
│   │       ├── scripts                 # Compose management scripts
│   │       ├── data-platform.yml       # MQ, Cache, DB etc
│   │       └── observability.yml
│   │
│   ├── docs
│   │   ├── adr                         # TBD
│   │   └── diagrams                    # TBD
│   │
│   ├── infrastructure                  # TBD
│   ├── platform-bom                    # Dependency management
│   ├── platform-config.yaml            # Config used by boostrap/compose scripts
│   ├── compose-up.ps1                  # Start all services
│   └── compose-down.ps1                # Stop all services
│   
├── bounded-contexts                    # Business services
│   ├── <some-service>
│   │   ├── src
│   │   ├── Dockerfile 
│   │   └── docker-compose.yml
│   └── ...
└── ...
```

## Bootstrap
Clones/updates services from `platform-config.yaml` to **bounded-contexts** directory.

### Usage
**Windows:**
```powershell
./bootstrap/main.ps1
```

## Local Development
### Start Services
**Create network and start all services:**
```powershell
./compose-up.ps1
```

**Create network and rebuild specific (business) services:**
```powershell
./compose-up.ps1 service1 service2
```
Rebuilds specified services with `--build --force-recreate`, starts the rest as-is.

### Stop Services
**Stop all services and remove network:**
```powershell
./compose-down.ps1
```