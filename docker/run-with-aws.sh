#!/bin/bash

# Script to run Conductor with AWS external services (RDS MySQL and ElastiCache Redis)

set -e

echo "Starting Conductor with AWS external services..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo "Please copy env.aws.example to .env and configure your AWS services:"
    echo "  cp env.aws.example .env"
    echo "  vim .env"
    exit 1
fi

# Source the .env file to validate required variables
export $(cat .env | grep -v '^#' | xargs)

# Check required environment variables
required_vars=("DB_HOST" "DB_USER" "DB_PASSWORD" "REDIS_HOST")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "ERROR: Missing required environment variables:"
    printf '%s\n' "${missing_vars[@]}"
    echo "Please update your .env file with the required values."
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p server/config

# Test connectivity to AWS services (optional)
echo "Testing connectivity to AWS services..."
echo -n "Testing RDS MySQL connection... "
if nc -zv $DB_HOST ${DB_PORT:-3306} 2>/dev/null; then
    echo "OK"
else
    echo "FAILED"
    echo "WARNING: Cannot connect to RDS MySQL at $DB_HOST:${DB_PORT:-3306}"
    echo "Please check your security groups and network configuration."
fi

echo -n "Testing ElastiCache Redis connection... "
if nc -zv $REDIS_HOST ${REDIS_PORT:-6379} 2>/dev/null; then
    echo "OK"
else
    echo "FAILED"
    echo "WARNING: Cannot connect to Redis at $REDIS_HOST:${REDIS_PORT:-6379}"
    echo "Please check your security groups and network configuration."
fi

# Build and start services
echo ""
echo "Building and starting Conductor services..."
docker-compose -f docker-compose-mysql-aws.yaml build
docker-compose -f docker-compose-mysql-aws.yaml up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service health
echo ""
echo "Checking service health..."
docker-compose -f docker-compose-mysql-aws.yaml ps

# Show logs for debugging if needed
if [ "$1" == "--logs" ]; then
    echo ""
    echo "Showing logs..."
    docker-compose -f docker-compose-mysql-aws.yaml logs -f
fi

echo ""
echo "Conductor is starting up!"
echo "Access points:"
echo "  - API: http://localhost:8080"
echo "  - UI: http://localhost:5001"
echo "  - Elasticsearch: http://localhost:9200"
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose -f docker-compose-mysql-aws.yaml logs -f"
echo "  - Stop services: docker-compose -f docker-compose-mysql-aws.yaml down"
echo "  - Restart services: docker-compose -f docker-compose-mysql-aws.yaml restart"
echo ""
echo "Check API health: curl http://localhost:8080/health" 