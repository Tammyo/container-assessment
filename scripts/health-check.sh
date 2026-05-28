#!/bin/bash
set -e

ALB_DNS=$1

if [ -z "$ALB_DNS" ]; then
  echo "Usage: ./health-check.sh <alb-dns-name>"
  exit 1
fi

echo "🔍 Running health checks against $ALB_DNS..."

MAX_RETRIES=5
RETRY_INTERVAL=10
SUCCESS=false

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i of $MAX_RETRIES..."
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/health)

  if [ "$RESPONSE" = "200" ]; then
    echo "✅ Health check passed! Status: $RESPONSE"
    SUCCESS=true
    break
  else
    echo "⚠️ Health check returned $RESPONSE, retrying in ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
  fi
done

if [ "$SUCCESS" = false ]; then
  echo "❌ Health check failed after $MAX_RETRIES attempts!"
  exit 1
fi
