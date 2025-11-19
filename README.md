# Platform Services

This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose

- Centralized platform for developing and testing application services
- Provides observability, configuration, authentication, API gateway, and other infrastructure components

## Documentation
Platform architecture and infrastructure documentation is maintained using [Structurizr Site Generator](https://github.com/avisi-cloud/structurizr-site-generatr) and automatically published to GitHub Pages.

### Source Files
- Documentation source: [`/docs`](./docs)
- Main workspace definition: [`/docs/workspace.dsl`](./docs/workspace.dsl)

### Generated Documentation
Interactive diagrams and documentation are available at:  
**https://komelgman.github.io/imanai-tap.platform/**

The documentation site is automatically regenerated on every push to `main` when files in `/docs` are modified.

## Project Structure

```
project-root
├── platform                            # This repo
│   ├── .github                         # CI workflows and hooks
│   ├── bootstrap                       # Scripts to initialize platform
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
│   ├── docs                            # TBD, generic example at now
│   │
│   ├── platform-services               # TBD
│   ├── platform-config.yaml            # Config used by boostrap/compose scripts
│   ├── compose-up.ps1                  # Start all services
│   └── compose-down.ps1                # Stop all services
│   
├── bounded-contexts                    # Business services
│   ├── <some-service>
│   │   ├── bootstrap                   # [Optional]
│   │   ├── src
│   │   ├── Dockerfile
│   │   └── docker-compose.yml
│   └── ...
└── ...
```

## Local Development

### Prerequisites

Ensure the following tools are installed on your system:

- Git - version control system
- Docker - container platform
- Docker Compose - multi-container orchestration tool

### Credentials for GitHub Packages

To enable your local maven to download project dependencies from GitHub Packages:

#### 1. Configure Maven Settings 

Add the following server configuration to your `settings.xml` file (located at `~/.m2/settings.xml`):

```xml
<server>
  <id>github-tap-platform</id>
  <username>${env.GH_USERNAME}</username>
  <password>${env.GH_PACKAGES_READ_TOKEN}</password>
</server>
```

#### 2. Set Environment Variables

Define the following environment variables in your system, used by local Maven and docker compose, to build services:

- `GH_USERNAME` — your GitHub username
- `GH_PACKAGES_READ_TOKEN` — a [Personal Access Token](https://github.com/settings/tokens) with `read:packages` scope

### Bootstrap

- Install git hooks
- Clones/updates services from `platform-config.yaml` to **bounded-contexts** directory

```powershell
./bootstrap/main.ps1
```

### Start Services

**Create network and start all services:**

```powershell
./compose-up.ps1
```

**To rebuild specific services use:**

```powershell
./compose-up.ps1 service1 service2
```

Rebuilds specified services with `--build --force-recreate`, starts the rest as-is.

### Stop Services

**Stop all services and remove network:**

```powershell
./compose-down.ps1
```
