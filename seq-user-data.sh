#!/usr/bin/env bash
set -e

# Log everything for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Seq installation at $(date)"

# updating system
yum update -y

# installing docker
yum install docker -y

# Create data directory for Seq
mkdir -p /data
chmod 755 /data

# activating docker
systemctl enable docker.service
systemctl start docker.service

# Wait for Docker to be ready
sleep 10

# Verify Docker is running
if ! systemctl is-active --quiet docker; then
    echo "ERROR: Docker failed to start"
    exit 1
fi

# Download and run Seq image
echo "Starting Seq container..."
docker run --name seq-server -d --restart unless-stopped \
    -e ACCEPT_EULA=Y \
    --mount type=bind,source=/data,target=/data \
    -p 80:80 -p 5341:5341 \
    datalust/seq:2025.2

# Wait a bit and verify container is running
sleep 15
if docker ps | grep -q seq-server; then
    echo "SUCCESS: Seq container is running"
    docker logs seq-server
else
    echo "ERROR: Seq container failed to start"
    docker logs seq-server || echo "No logs available"
    exit 1
fi

echo "Seq installation completed at $(date)"