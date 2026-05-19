# Architecture

## Overview

This is a full-stack monitoring system with observability built in.

## Components

### Application Layer
- **API**: Node.js backend service
- **Web**: React/Vue frontend served via Nginx
- **PostgreSQL**: Primary database
- **Redis**: Cache and session storage

### Infrastructure Layer
- **Traefik**: Reverse proxy and load balancer
  - Routes traffic based on host headers
  - Automatic service discovery via Docker labels

### Monitoring Layer
- **Prometheus**: Metrics collection and storage
  - Scrapes metrics from exporters
  - Time-series database
- **Grafana**: Visualization dashboard
  - Connects to Prometheus for metrics
  - Connects to Loki for logs
- **Loki**: Log aggregation system
  - Efficient log storage
  - Label-based querying
- **Promtail**: Log agent
  - Collects logs from Docker containers
  - Sends to Loki
- **Node Exporter**: System metrics
  - CPU, memory, disk, network
- **cAdvisor**: Container metrics
  - Resource usage per container

## Data Flow

```
User → Traefik → Web/API
                ↓
            PostgreSQL
                ↓
                Redis

Containers → Promtail → Loki → Grafana
            ↓
         Node Exporter → Prometheus → Grafana
            ↓
            cAdvisor → Prometheus → Grafana
```

## Network Architecture

All services communicate via the `internal` Docker network. Only Traefik and monitoring services expose ports to the host.

## Security Considerations

- Use strong passwords in production (see `.env.example`)
- Change default Grafana credentials
- Use HTTPS in production (Traefik SSL configuration)
- Restrict Traefik dashboard access
- Enable PostgreSQL authentication
