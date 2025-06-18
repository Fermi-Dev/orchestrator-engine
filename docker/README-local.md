# Local Conductor Deployment

This setup allows you to run Conductor with your own MySQL and Redis instances running on your host machine.

## Prerequisites

1. **MySQL** running on your host machine (port 3306)
2. **Redis** running on your host machine (port 6379)
3. **Docker** and **Docker Compose** installed

## Setup Instructions

### 1. Configure Environment Variables

Copy the environment file and modify it according to your setup:

```bash
cp env.local .env
```

The default configuration uses:
- **Database**: `fermi_flow`
- **User**: `fermi_flow_user`
- **Password**: `fermi_flow_password`

Edit `.env` file if you need different values:

```bash
# MySQL Configuration
MYSQL_HOST=host.docker.internal
MYSQL_PORT=3306
MYSQL_DATABASE=fermi_flow
MYSQL_USERNAME=fermi_flow_user
MYSQL_PASSWORD=fermi_flow_password

# Redis Configuration
REDIS_HOST=host.docker.internal
REDIS_PORT=6379

# Port Configuration
CONDUCTOR_SERVER_PORT=8080
CONDUCTOR_METRICS_PORT=8127
CONDUCTOR_UI_PORT=5000
ELASTICSEARCH_PORT=9201
```

### 2. Prepare MySQL Database

Create the fermi_flow database and user in your MySQL instance:

```sql
CREATE DATABASE fermi_flow;
CREATE USER 'fermi_flow_user'@'%' IDENTIFIED BY 'fermi_flow_password';
GRANT ALL PRIVILEGES ON fermi_flow.* TO 'fermi_flow_user'@'%';
FLUSH PRIVILEGES;
```

### 3. Build Docker Images

From the project root directory:

```bash
# Build server image
docker build -f docker/server/Dockerfile -t conductor:server .

# Build UI image
docker build -f docker/ui/Dockerfile -t conductor:ui .
```

### 4. Start Services

```bash
cd docker
docker-compose -f docker-compose-local.yaml --env-file .env up -d
```

### 5. Verify Deployment

- **Conductor Server**: http://localhost:8080
- **Conductor UI**: http://localhost:5000
- **Elasticsearch**: http://localhost:9201
- **Metrics**: http://localhost:8127/actuator/prometheus

## Troubleshooting

### Connection Issues

If containers can't connect to your host MySQL/Redis:

1. **macOS/Windows**: Use `host.docker.internal` (already configured)
2. **Linux**: Replace `host.docker.internal` with your host IP address in `.env`

### Port Conflicts

If you have port conflicts, modify the ports in `.env`:

```bash
CONDUCTOR_SERVER_PORT=8081
CONDUCTOR_UI_PORT=5001
ELASTICSEARCH_PORT=9202
```

### Database Connection

Ensure your MySQL instance allows connections from Docker containers:

```sql
-- Allow connections from any host (for Docker)
GRANT ALL PRIVILEGES ON fermi_flow.* TO 'fermi_flow_user'@'%';
FLUSH PRIVILEGES;
```

## Stopping Services

```bash
docker-compose -f docker-compose-local.yaml down
```

## Cleanup

To remove all data and start fresh:

```bash
docker-compose -f docker-compose-local.yaml down -v
```

This will remove the Elasticsearch volume. MySQL and Redis data on your host machine will remain unchanged. 