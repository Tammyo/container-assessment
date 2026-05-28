#!/bin/bash
set -e

echo "Running health check..."

ALB_NAME=${1:-"starttech-alb"}
MAX_RETRIES=${2:-10}
RETRY_INTERVAL=${3:-15}

ALB_DNS=$(aws elbv2 describe-load-balancers \
  --names $ALB_NAME \
  --query 'LoadBalancers[0].DNSName' \
  --output text)

if [ -z "$ALB_DNS" ]; then
  echo "Could not find ALB: $ALB_NAME"
  exit 1
fi

echo "Checking health at http://$ALB_DNS/health"

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i/$MAX_RETRIES..."
  if curl -sf http://$ALB_DNS/health; then
    echo "Health check passed!"
    exit 0
  fi
  echo "Not ready yet, waiting ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

echo "Health check failed after $MAX_RETRIES attempts!"
exit 1
