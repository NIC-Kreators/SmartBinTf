#!/bin/bash
# Enable logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update system packages
yum update -y

# Install curl for health checks
yum install -y curl

# Configure ECS agent
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# Start ECS agent
start ecs

# Wait for ECS agent to be ready
sleep 30

echo "User data script completed successfully"