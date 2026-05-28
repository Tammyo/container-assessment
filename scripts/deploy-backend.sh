#!/bin/bash
set -e

echo "🚀 Deploying backend to EC2..."

AWS_REGION="us-east-1"
ECR_REPOSITORY="starttech-backend"
ASG_NAME=$1

if [ -z "$ASG_NAME" ]; then
  echo "Usage: ./deploy-backend.sh <asg-name>"
  exit 1
fi

echo "🔑 Logging into ECR..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

echo "🔨 Building Docker image..."
cd "$(dirname "$0")/../Server/MuchToDo"
IMAGE_TAG=$(git rev-parse --short HEAD)
docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest

echo "📤 Pushing to ECR..."
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

echo "🚀 Deploying to EC2 instances..."
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
  --output text)

for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Deploying to $INSTANCE_ID..."
  aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "AWS-RunShellScript" \
    --parameters commands="[
      'docker pull $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG',
      'docker stop starttech-backend || true',
      'docker rm starttech-backend || true',
      'docker run -d --name starttech-backend --restart always -p 8080:8080 $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG'
    ]" \
    --region $AWS_REGION
done

echo "✅ Backend deployed successfully!"
