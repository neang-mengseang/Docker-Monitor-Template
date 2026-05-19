# Setup Guide

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Node.js 18+ (for local development)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd monitoring-fullstack
```

### 2. Configure Environment Variables

```bash
cp infra/.env.example infra/.env
# Edit infra/.env with your values
```

### 3. Start Core Services

```bash
cd infra
docker compose up -d
```

This starts:
- Traefik (reverse proxy)
- API (backend)
- Web (frontend)
- PostgreSQL (database)
- Redis (cache)

### 4. Start Monitoring Stack (Optional)

```bash
docker compose --profile monitoring up -d
```

This starts additional services:
- Grafana (dashboard)
- Prometheus (metrics)
- Loki (logs)
- Promtail (log agent)
- Node Exporter (system metrics)
- cAdvisor (container metrics)

## Access Services

- **Web**: http://localhost
- **API**: http://api.localhost
- **Traefik Dashboard**: http://localhost:8081
- **Grafana**: http://localhost:3000 (admin/strongpassword)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

## Development Setup

### API Development

```bash
cd apps/api
npm install
npm run dev
```

### Web Development

```bash
cd apps/web
npm install
npm run dev
```

## Production Deployment

1. Update environment variables with production values
2. Set up proper backup strategy for PostgreSQL
3. Configure log retention policies in Loki
4. Set up alerting rules in Prometheus
5. Use a reverse proxy (nginx/caddy) for SSL termination

## Troubleshooting

### Containers Won't Start

```bash
docker compose logs
docker compose ps
```

### Database Connection Issues

Check PostgreSQL is running:
```bash
docker compose ps postgres
```

### Monitoring Not Working

Ensure monitoring profile is enabled:
```bash
docker compose --profile monitoring up -d
```

### View Logs

```bash
docker compose logs -f [service-name]
```

## Stopping Services

```bash
# Stop all services
docker compose down

# Stop including monitoring
docker compose --profile monitoring down

# Stop and remove volumes (WARNING: deletes data)
docker compose down -v
```
