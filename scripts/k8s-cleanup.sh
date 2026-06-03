#!/bin/bash
set -e

echo "Cleaning up Kubernetes resources..."

CLUSTER_NAME=${1:-"muchtodo-cluster"}

# Delete all resources in namespace
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found
kubectl delete -f kubernetes/backend/ --ignore-not-found
kubectl delete -f kubernetes/mongodb/ --ignore-not-found
kubectl delete -f kubernetes/namespace.yaml --ignore-not-found

# Delete Kind cluster
echo "Deleting Kind cluster..."
kind delete cluster --name $CLUSTER_NAME

echo "Cleanup complete!"
