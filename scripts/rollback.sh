#!/bin/bash
set -e

echo "⏪ Rolling back deployment..."

AWS_REGION="us-east-1"
ECR_REPOSITORY="starttech-backend"
ASG_NAME=$1
ROLLBACK_TAG=$2

if [ -z "$ASG_NAME" ] || [ -z "$ROLLBACK_TAG" ]; then
  echo "Usage: ./rollback.sh <asg-name> <image-tag-to-rollback-to>"
  exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$ECR_REPOSITORY:$ROLLBACK_TAG"

echo "🔄 Rolling back to image: $IMAGE"

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text)

for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Rolling back instance $INSTANCE_ID..."
  aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "AWS-RunShellScript" \
    --parameters commands="[
      'docker pull $IMAGE',
      'docker stop starttech-backend || true',
      'docker rm starttech-backend || true',
      'docker run -d --name starttech-backend --restart always -p 8080:8080 $IMAGE'
    ]" \
    --region $AWS_REGION
done

echo "✅ Rollback complete!"
