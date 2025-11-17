# Platform Services

This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose

- Centralized platform for developing and testing application services
- Provides observability, configuration, authentication, API gateway, and other infrastructure components

## Project Structure

```
project-root
├── platform                            # This repo
│   ├── .github                         # CI workflows and hooks
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
│   │   ├── adr 
│   │   └── diagrams                    # TBD
│   │
│   ├── platform-services               # TBD
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

## Local Development

### Credentials for GitHub Packages

## IDE Configuration for GitHub Packages

To enable your IDE to download project dependencies from GitHub Packages, configure your local Maven settings:

### 1. Configure Maven Settings

Add the following server configuration to your `settings.xml` file (located at `~/.m2/settings.xml`):

```xml
<server>
  <id>github-tap-platform</id>
  <username>${env.GITHUB_USERNAME}</username>
  <password>${env.GITHUB_PAT}</password>
</server>
```

### 2. Set Environment Variables

Define the following environment variables in your system:

- `GITHUB_USERNAME` — your GitHub username
- `GITHUB_PAT` — a [Personal Access Token](https://github.com/settings/tokens) with `read:packages` scope

### Bootstrap

* Clones/updates services from `platform-config.yaml` to **bounded-contexts** directory;
* Install pre-commit hooks.

```powershell
./bootstrap/main.ps1
```

### Start Services

**Create network and start all services:**

```powershell
./compose-up.ps1
```

**To rebuild specific (business) services use:**

```powershell
./compose-up.ps1 service1 service2
```

Rebuilds specified services with `--build --force-recreate`, starts the rest as-is.

### Stop Services

**Stop all services and remove network:**

```powershell
./compose-down.ps1
```
