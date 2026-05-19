# Sentinel

A production-ready monitoring system with comprehensive observability for servers, containers, and applications. This setup provides complete visibility into your infrastructure with metrics collection, log aggregation, and visualization dashboards.

## What This System Monitors

### Server/Host Level (via Node Exporter)
- **CPU**: Usage, load, cores, frequency
- **Memory**: Total, used, free, cached, buffers
- **Disk**: I/O operations, space usage, filesystem stats
- **Network**: Traffic, connections, errors, packet loss
- **System**: Uptime, processes, kernel stats

### Container Level (via cAdvisor)
- **All Docker containers** on the host
- **Per-container metrics**: CPU, memory, network I/O, disk I/O
- **Container health**: Status, restarts, resource limits
- **Image layers**: Size, cache usage

### Application Level
- **Custom metrics**: Via Prometheus exporters
- **Application logs**: Centralized in Loki
- **Health checks**: API endpoints monitoring

### Log Aggregation (via Loki + Promtail)
- **Centralized logging**: All container logs in one place
- **Label-based queries**: Filter logs by container, service, etc.
- **Retention policies**: Configure log storage duration
- **Real-time streaming**: View logs as they happen

## Features

- **Monitoring Stack**: Prometheus, Grafana, Loki, Promtail
- **System Metrics**: Node Exporter for host metrics
- **Container Metrics**: cAdvisor for container-level monitoring
- **Log Aggregation**: Centralized logging with Loki
- **Visualization**: Grafana dashboards for metrics and logs
- **Alerting**: Prometheus alerting rules (configurable)
- **Reverse Proxy Compatible**: Works with any reverse proxy (Nginx, Caddy, Traefik, etc.)
- **Windows Support**: Works on Windows with Docker Desktop (WSL2)
- **Production Ready**: Persistent volumes, health checks, auto-restart
- **Optional Sample App**: Demo application (API + Web + PostgreSQL + Redis) for reference

## Project Structure

```
monitoring-fullstack/
├── docker-compose.yml    # Docker Compose configuration
├── .env.example          # Environment variables template
├── prometheus.yml        # Prometheus metrics configuration
├── loki.yml              # Loki log aggregation configuration
├── promtail.yml          # Promtail log agent configuration
├── setup.ps1             # Windows one-click setup script
├── setup.sh              # Linux/Mac one-click setup script
├── apps/                 # Sample application (ignored in git)
│   ├── api/              # Node.js backend
│   └── web/              # Frontend application
├── docs/                 # Documentation
│   ├── architecture.md
│   ├── setup.md
│   └── monitoring-services.md
└── README.md
```

## One-Click Setup

### Windows
```powershell
# Run the setup script
.\setup.ps1
```

### Linux/Mac
```bash
# Make script executable and run
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Check Docker installation
- Create .env file from template
- Start all services (core + monitoring)
- Display access URLs

### Manual Setup
```bash
# Copy environment file
cp .env.example .env

# Edit .env to change default passwords and ports if needed
# nano .env  # or your preferred editor

# Start monitoring stack only (recommended)
docker compose up -d

# Start with sample app (optional)
docker compose --profile app up -d
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

**Grafana (required):**
- `GF_SECURITY_ADMIN_USER` - Grafana admin username (default: admin)
- `GF_SECURITY_ADMIN_PASSWORD` - Grafana admin password (change for production)

**Database (only if using sample app):**
- `POSTGRES_DB` - Database name (default: app)
- `POSTGRES_USER` - Database user (default: postgres)
- `POSTGRES_PASSWORD` - Database password (change for production)

**Ports** (change if conflicts):
- `API_PORT` - API service port (default: 3001) - only with sample app
- `WEB_PORT` - Web frontend port (default: 8080) - only with sample app
- `GRAFANA_PORT` - Grafana port (default: 3000)
- `PROMETHEUS_PORT` - Prometheus port (default: 9090)
- `LOKI_PORT` - Loki port (default: 3100)
- `NODE_EXPORTER_PORT` - Node Exporter port (default: 9100)
- `CADVISOR_PORT` - cAdvisor port (default: 8082)

## Access Services

**Monitoring Services (always available):**
- **Grafana**: http://localhost:3000 (default: admin/strongpassword — change in `.env`)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100
- **cAdvisor**: http://localhost:8082
- **Node Exporter**: http://localhost:9100

**Sample App (only with `--profile app`):**
- **Web**: http://localhost:8080
- **API**: http://localhost:3001
- **API Health**: http://localhost:3001/health

## Documentation

- [Architecture](docs/architecture.md) - System architecture and components
- [Setup Guide](docs/setup.md) - Detailed setup instructions
- [Monitoring Services](docs/monitoring-services.md) - How to add your own services to monitor

## Use Cases

- **DevOps Monitoring**: Monitor development and production infrastructure
- **Server Health**: Track server performance and resource usage
- **Container Orchestration**: Monitor Docker containers and Kubernetes pods
- **Application Performance**: Track API response times, error rates, throughput
- **Log Analysis**: Centralized log viewing and debugging
- **Capacity Planning**: Forecast resource needs based on historical data
- **Incident Response**: Quick identification of issues with metrics and logs

## Architecture Overview

```
Applications → Metrics → Prometheus → Grafana (Dashboards)
              ↓
            Logs → Promtail → Loki → Grafana (Log Viewer)
              ↓
         Node Exporter → System Metrics → Prometheus
              ↓
            cAdvisor → Container Metrics → Prometheus
```

## Platform Compatibility

- **Linux**: Full support with all metrics
- **Windows**: Works with Docker Desktop (WSL2), some metrics limited
- **macOS**: Works with Docker Desktop, similar limitations as Windows

## Reverse Proxy Integration

This system is compatible with any reverse proxy:
- **Nginx**: Route domains to specific ports
- **Caddy**: Automatic HTTPS with simple configuration
- **Traefik**: Docker-native reverse proxy
- **HAProxy**: Enterprise-grade load balancing
- **Cloudflare**: CDN and reverse proxy

Configure your reverse proxy to forward traffic to:
- Web: `localhost:8080`
- API: `localhost:3001`
- Grafana: `localhost:3000`
- Prometheus: `localhost:9090`
- Loki: `localhost:3100`

## License

MIT
