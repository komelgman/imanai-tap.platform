# Platform Services

This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose

- Centralized platform for developing and testing application services.
- Provides observability, configuration, authentication, API gateway, and other infrastructure components.

## Current Status

Currently, the **Observability stack** is deployed via Docker Compose:

- Grafana Alloy
- Grafana
- Loki
- Tempo
- Mimir
- Pyroscope _not configured yet_

## Project structure

```
 project-root
 ├── platform                           -- This repo
 │   ├── bootstrap                      -- Scripts to initialize platform directories and clone services
 │   │   ├── .tools
 │   │   ├── /scripts/*
 │   │   ├── main.sh / main.ps1         -- Entry point for bootstrap, !sic .sh TBD
 │   │   └── platform-config.yaml       -- List of bostrapped services
 │   ├── deployment
 │   │   ├── helm                       -- TBD
 │   │   └── docker-compose             -- Local dev
 │   │       ├── observability          -- Observability configuaration 
 │   │       └── docker-compose.yml
 │   ├── docs
 │   │   ├── adr                        -- TBD
 │   │   └── diagrams                   -- TBD
 │   │
 │   ├── platform-bom                   -- Dependency management
 │   └── infrastructure                 -- TBD: infrastructure modules
 │   
 ├── bounded-contexts                   -- Folder for Business Services
 │   ├── mds.historical                 -- Business Service
 │   │   ├── src
 │   │   └── Dockerfile
 │   └── ...
 └── ...
```

# Platform Services

This repository contains platform and infrastructure services shared across all bounded contexts of the project.

## Purpose

* Centralized platform for developing and testing application services.
* Provides observability, configuration, authentication, API gateway, and other infrastructure components.

## Current Status

Currently, the **Observability stack** is deployed via Docker Compose:

* Grafana Alloy
* Grafana
* Loki
* Tempo
* Mimir
* Pyroscope *not configured yet*

## Bootstrap

The bootstrap module is responsible for initializing the platform structure and fetching required repositories automatically.

* **Purpose:** 
  * Prepare `bounded-contexts` directories and clone/update service repositories according to `platform-config.yaml`.
  * Add docker network.

### Usage

Linux:

```bash
./bootstrap/main.sh
```

Windows:

```powershell
./bootstrap/main.ps1
```
