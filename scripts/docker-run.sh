#!/bin/bash
set -e

echo "Starting application with docker-compose..."

docker-compose up --build -d

echo "Waiting for services to be healthy..."
sleep 10

echo "Checking application health..."
curl -f http://localhost:8080/health

echo "Application is running at http://localhost:8080"
