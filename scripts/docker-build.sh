#!/bin/bash
set -e

echo "Building Docker image..."

IMAGE_NAME=${1:-"muchtodo-backend"}
IMAGE_TAG=${2:-"latest"}

docker build -t $IMAGE_NAME:$IMAGE_TAG .

echo "Docker image built: $IMAGE_NAME:$IMAGE_TAG"
