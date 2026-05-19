# One-Click Setup Script for Monitoring System (Windows)
# Run this script to set up and start the monitoring system

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Monitoring System One-Click Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    docker --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker is installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is available
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
try {
    docker compose version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker Compose is available" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker Compose is not available." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Docker Compose is not available." -ForegroundColor Red
    exit 1
}

# Create .env file if it doesn't exist
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ .env file created" -ForegroundColor Green
} else {
    Write-Host "✓ .env file already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting services..." -ForegroundColor Yellow

# Start all services
Write-Host "Starting monitoring stack..." -ForegroundColor Yellow
docker compose up -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Monitoring stack started" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to start services" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Sample app is optional. To start it, run:" -ForegroundColor Yellow
Write-Host "  docker compose --profile app up -d"

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access the services:" -ForegroundColor White
Write-Host "  Grafana:       http://localhost:3000 (admin/strongpassword)" -ForegroundColor White
Write-Host "  Prometheus:    http://localhost:9090" -ForegroundColor White
Write-Host "  Loki:          http://localhost:3100" -ForegroundColor White
Write-Host "  cAdvisor:      http://localhost:8082" -ForegroundColor White
Write-Host "  Node Exporter: http://localhost:9100" -ForegroundColor White
Write-Host ""
Write-Host "Sample App (optional - run with --profile app):" -ForegroundColor White
Write-Host "  Web:           http://localhost:8080" -ForegroundColor White
Write-Host "  API:           http://localhost:3001" -ForegroundColor White
Write-Host "  API Health:    http://localhost:3001/health" -ForegroundColor White
Write-Host ""
Write-Host "To stop services:" -ForegroundColor White
Write-Host "  docker compose down" -ForegroundColor White
Write-Host ""
