#!/bin/bash

# One-Click Setup Script for Monitoring System (Linux/Server)
# Run this script to set up and start the monitoring system
# Optimized for production server environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================${NC}"
echo -e "${CYAN}Monitoring System One-Click Setup${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Running as root - this is not recommended for production${NC}"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Docker is installed
echo -e "${YELLOW}Checking Docker installation...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
    docker --version
else
    echo -e "${RED}✗ Docker is not installed. Please install Docker first.${NC}"
    echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com | sh"
    echo "  CentOS/RHEL: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# Check if Docker daemon is running
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if docker info &> /dev/null; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${RED}✗ Docker daemon is not running. Please start Docker.${NC}"
    echo "  sudo systemctl start docker"
    exit 1
fi

# Check if Docker Compose is available
echo -e "${YELLOW}Checking Docker Compose...${NC}"
if docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose is available${NC}"
    docker compose version
else
    echo -e "${RED}✗ Docker Compose is not available.${NC}"
    echo "  Install Docker Compose V2: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if user is in docker group (not root)
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Checking Docker group membership...${NC}"
    if groups $USER | grep -q docker; then
        echo -e "${GREEN}✓ User is in docker group${NC}"
    else
        echo -e "${YELLOW}⚠ User is not in docker group - you may need sudo${NC}"
        echo "  Add user to docker group: sudo usermod -aG docker $USER"
        echo "  Then logout and login again"
    fi
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}⚠ Please review .env and update passwords for production${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""
echo -e "${YELLOW}Starting services...${NC}"

# Pull latest images
echo -e "${YELLOW}Pulling latest Docker images...${NC}"
docker compose pull

# Start all services
echo -e "${YELLOW}Starting all services...${NC}"
docker compose up -d
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All services started${NC}"
else
    echo -e "${RED}✗ Failed to start services${NC}"
    echo "Check logs: docker compose logs"
    exit 1
fi

echo ""
echo -e "${CYAN}====================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}====================================${NC}"
echo ""
echo -e "${YELLOW}Access the services:${NC}"
echo -e "  Web:           http://localhost:8080"
echo -e "  API:           http://localhost:3001"
echo -e "  API Health:    http://localhost:3001/health"
echo -e "  Grafana:       http://localhost:3000 (admin/strongpassword)"
echo -e "  Prometheus:    http://localhost:9090"
echo -e "  Loki:          http://localhost:3100"
echo ""
echo -e "${YELLOW}Server IP:${NC}"
echo -e "  $(hostname -I | awk '{print $1}')"
echo ""
echo -e "${YELLOW}To stop services:${NC}"
echo -e "  docker compose down"
echo ""
echo -e "${YELLOW}To view logs:${NC}"
echo -e "  docker compose logs -f"
echo ""
echo -e "${YELLOW}Production notes:${NC}"
echo -e "  1. Change default passwords in .env"
echo -e "  2. Configure firewall rules"
echo -e "  3. Set up SSL/HTTPS"
echo -e "  4. Configure backup strategy"
echo ""

