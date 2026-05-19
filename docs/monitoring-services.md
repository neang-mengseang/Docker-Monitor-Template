# Adding Services to Monitor

This guide explains how to add your own services to be monitored by the monitoring stack.

## Automatic Monitoring

The following are **automatically monitored** without any configuration:

- **All Docker containers** - via cAdvisor (CPU, memory, network, disk I/O)
- **Host system** - via Node Exporter (CPU, memory, disk, network)
- **Container logs** - via Promtail (if configured correctly)

## Adding Custom Services

To monitor a custom application, you need to expose a metrics endpoint.

### 1. Metrics Endpoint Requirements

Your service should expose metrics in Prometheus format at an HTTP endpoint, typically:

- **Endpoint**: `/metrics`
- **Format**: Prometheus text format
- **Content**: Metrics in the format: `metric_name{label="value"} value`

#### Example Metrics Response

```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/api/users",status="200"} 1234
http_requests_total{method="POST",path="/api/users",status="201"} 56
http_requests_total{method="GET",path="/api/users",status="404"} 12

# HELP http_request_duration_seconds Duration of HTTP requests in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",path="/api/users",le="0.1"} 1000
http_request_duration_seconds_bucket{method="GET",path="/api/users",le="0.5"} 1100
http_request_duration_seconds_bucket{method="GET",path="/api/users",le="1.0"} 1150
http_request_duration_seconds_bucket{method="GET",path="/api/users",le="+Inf"} 1234
http_request_duration_seconds_sum{method="GET",path="/api/users"} 45.2
http_request_duration_seconds_count{method="GET",path="/api/users"} 1234

# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 12.34

# HELP process_resident_memory_bytes Resident memory size in bytes
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 52428800

# HELP go_goroutines Number of goroutines that currently exist
# TYPE go_goroutines gauge
go_goroutines 15
```

### 2. Example: Node.js Application

```javascript
const promClient = require('prom-client');
const express = require('express');

const app = express();

// Create a Registry
const register = new promClient.Registry();

// Add default metrics (CPU, memory, etc.)
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000);
```

### 3. Example: Python Application

```python
from prometheus_client import start_http_server, Counter, Histogram
import random
import time

# Create metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests')
REQUEST_LATENCY = Histogram('http_request_latency_seconds', 'HTTP request latency')

# Expose metrics on port 8000
start_http_server(8000)

# Your application code
while True:
    REQUEST_COUNT.inc()
    REQUEST_LATENCY.observe(random.random())
    time.sleep(1)
```

### 4. Example: Go Application

```go
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
    "net/http"
)

var (
    requestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "path"},
    )
)

func init() {
    prometheus.MustRegister(requestsTotal)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

## Configuration Steps

### Step 1: Add Service to docker-compose.yml

```yaml
services:
  my-service:
    image: my-service:latest
    ports:
      - "8080:8080"
    networks:
      - internal
```

### Step 2: Add Prometheus Scrape Config

Edit `prometheus.yml`:

```yaml
scrape_configs:
  # ... existing configs ...

  - job_name: 'my-service'
    static_configs:
      - targets: ['my-service:8080']
        labels:
          service: 'my-service'
          environment: 'production'
```

### Step 3: Restart Services

```bash
docker compose up -d
docker compose restart prometheus
```

### Step 4: Add Data Source in Grafana

1. Go to Grafana → Configuration → Data Sources
2. Add Prometheus data source (already configured)
3. Create/import dashboards using the metrics

## Common Services Examples

### PostgreSQL with Exporter

```yaml
services:
  postgres-exporter:
    image: quay.io/prometheuscommunity/postgres-exporter
    environment:
      DATA_SOURCE_NAME: "postgresql://user:password@postgres:5432/dbname"
    ports:
      - "9187:9187"
    networks:
      - internal
```

Prometheus config:
```yaml
- job_name: 'postgres'
  static_configs:
    - targets: ['postgres-exporter:9187']
```

### Redis with Exporter

```yaml
services:
  redis-exporter:
    image: oliver006/redis_exporter
    environment:
      REDIS_ADDR: "redis:6379"
    ports:
      - "9121:9121"
    networks:
      - internal
```

Prometheus config:
```yaml
- job_name: 'redis'
  static_configs:
    - targets: ['redis-exporter:9121']
```

### Nginx with Exporter

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf

  nginx-exporter:
    image: nginx/nginx-prometheus-exporter
    command:
      - -nginx.scrape-uri=http://nginx:80/nginx_status
    ports:
      - "9113:9113"
    networks:
      - internal
```

Prometheus config:
```yaml
- job_name: 'nginx'
  static_configs:
    - targets: ['nginx-exporter:9113']
```

## Best Practices

1. **Use meaningful metric names** - Follow Prometheus naming conventions
2. **Add labels** - Include useful dimensions like service, environment, status
3. **Document metrics** - Add `help` text to explain what each metric means
4. **Keep metrics lightweight** - Don't expose too many high-cardinality metrics
5. **Use standard libraries** - Use official Prometheus client libraries

## Troubleshooting

### Metrics not appearing in Prometheus

- Check if service exposes `/metrics` endpoint: `curl http://service:port/metrics`
- Verify Prometheus config syntax: `docker compose config`
- Check Prometheus logs: `docker logs prometheus`
- Verify service is in same Docker network

### High cardinality warnings

- Reduce number of unique label values
- Use bounded label sets
- Consider using histograms for high-cardinality data

### Service not reachable

- Ensure services are in the same Docker network
- Check container names match Prometheus config
- Verify ports are correctly mapped

## Further Reading

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Prometheus Client Libraries](https://prometheus.io/docs/instrumenting/clientlibs/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
