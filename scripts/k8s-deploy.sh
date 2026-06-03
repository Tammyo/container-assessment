#!/bin/bash
set -e

echo "Deploying to Kubernetes..."

CLUSTER_NAME=${1:-"muchtodo-cluster"}

# Create Kind cluster if it doesn't exist
if ! kind get clusters | grep -q $CLUSTER_NAME; then
  echo "Creating Kind cluster..."
  kind create cluster --name $CLUSTER_NAME
fi

# Load image into Kind cluster
echo "Loading Docker image into Kind cluster..."
kind load docker-image muchtodo-backend:latest --name $CLUSTER_NAME

# Apply manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n muchtodo --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n muchtodo --timeout=120s

echo "Deployment complete!"
kubectl get all -n muchtodo
