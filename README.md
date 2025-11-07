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

```lua
 project-root
 ├── platform                           -- This repo
 │   ├── docs
 │   │   ├── adr                        -- TBD
 │   │   └── diagrams                   -- TBD
 │   ├── deployment
 │   │   └── docker-compose
 │   │       ├── observability          -- Observability configuaration 
 │   │       └── docker-compose.yml    
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