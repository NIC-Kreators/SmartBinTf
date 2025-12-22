#!/bin/bash

# Script to update Seq API key in AWS Secrets Manager after Seq deployment
# Usage: ./update-seq-api-key.sh <seq-api-key>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <seq-api-key>"
    echo "Example: $0 seq20252smartbin\$secured*apikey"
    exit 1
fi

SEQ_API_KEY="$1"
PROJECT_NAME=$(terraform output -raw project_name 2>/dev/null || echo "smartbin")
SECRET_NAME="${PROJECT_NAME,,}-api-secrets"

echo "Updating Seq API key in AWS Secrets Manager..."
echo "Secret name: $SECRET_NAME"

# Get current secret value
CURRENT_SECRET=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)

# Update the SEQ_API_KEY value in the JSON
UPDATED_SECRET=$(echo "$CURRENT_SECRET" | jq --arg key "$SEQ_API_KEY" '.SEQ_API_KEY = $key')

# Update the secret
aws secretsmanager update-secret --secret-id "$SECRET_NAME" --secret-string "$UPDATED_SECRET"

echo "✅ Seq API key updated successfully!"
echo "🔄 ECS service will pick up the new key on next deployment or restart"

# Optional: Force ECS service update to pick up new secret immediately
read -p "Do you want to restart the ECS service to pick up the new key immediately? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    CLUSTER_NAME="${PROJECT_NAME,,}-cluster"
    SERVICE_NAME="${PROJECT_NAME,,}-api-service"
    
    echo "Restarting ECS service..."
    aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --force-new-deployment
    echo "✅ ECS service restart initiated!"
fi