# MuchTodo - Container Assessment

Golang backend API containerized with Docker and deployed to Kubernetes using Kind.

## Prerequisites
- Docker
- Docker Compose
- Kind
- Kubectl

## Phase 1: Docker

### Build the image
./scripts/docker-build.sh

### Run with docker-compose
./scripts/docker-run.sh

### Access the application
curl http://localhost:8080/health

### Stop the application
docker-compose down

## Phase 2: Kubernetes

### Deploy to Kind cluster
./scripts/k8s-deploy.sh

### Check status
kubectl get all -n muchtodo

### Access via NodePort
curl http://localhost:30080/health

### Cleanup
./scripts/k8s-cleanup.sh

## Environment Variables
- MONGO_URI: MongoDB connection string
- PORT: Application port (default 8080)

## Architecture
- Backend: Golang API running on port 8080
- Database: MongoDB with persistent storage
- Namespace: muchtodo
- Backend replicas: 2
- MongoDB replicas: 1
