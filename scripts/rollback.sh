#!/bin/bash
set -e

echo "Rolling back backend deployment..."

ASG_NAME=${1:-"starttech-backend-asg"}
PREVIOUS_IMAGE_URI=$2
AWS_REGION=${3:-"us-east-1"}

if [ -z "$PREVIOUS_IMAGE_URI" ]; then
  echo "Usage: ./rollback.sh <asg-name> <previous-image-uri> <aws-region>"
  exit 1
fi

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text)

echo "Rolling back to: $PREVIOUS_IMAGE_URI"
for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Rolling back $INSTANCE_ID..."
  aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands=["docker pull $PREVIOUS_IMAGE_URI","docker stop starttech-backend || true","docker rm starttech-backend || true","docker run -d --name starttech-backend -p 8080:8080 --restart always $PREVIOUS_IMAGE_URI"] \
    --region $AWS_REGION
done

echo "Rollback complete!"
