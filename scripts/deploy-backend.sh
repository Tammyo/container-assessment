#!/bin/bash
set -e

echo "Deploying backend to EC2 via ASG..."

ASG_NAME=${1:-"starttech-backend-asg"}
IMAGE_URI=$2
AWS_REGION=${3:-"us-east-1"}

if [ -z "$IMAGE_URI" ]; then
  echo "Usage: ./deploy-backend.sh <asg-name> <image-uri> <aws-region>"
  exit 1
fi

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "No instances found in ASG: $ASG_NAME"
  exit 1
fi

for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Deploying to $INSTANCE_ID..."
  aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands=["docker pull $IMAGE_URI","docker stop starttech-backend || true","docker rm starttech-backend || true","docker run -d --name starttech-backend -p 8080:8080 --restart always $IMAGE_URI"] \
    --region $AWS_REGION
done

echo "Backend deployment complete!"
