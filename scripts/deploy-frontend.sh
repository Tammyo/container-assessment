#!/bin/bash
set -e

echo "🚀 Deploying frontend to S3..."

S3_BUCKET=$1
CLOUDFRONT_ID=$2

if [ -z "$S3_BUCKET" ] || [ -z "$CLOUDFRONT_ID" ]; then
  echo "Usage: ./deploy-frontend.sh <s3-bucket-name> <cloudfront-distribution-id>"
  exit 1
fi

cd "$(dirname "$0")/../Client"

echo "📦 Installing dependencies..."
npm ci

echo "🔨 Building production bundle..."
npm run build

echo "☁️ Syncing to S3..."
aws s3 sync dist/ s3://$S3_BUCKET \
  --delete \
  --cache-control "public, max-age=31536000" \
  --exclude "index.html"

aws s3 cp dist/index.html s3://$S3_BUCKET/index.html \
  --cache-control "no-cache, no-store, must-revalidate"

echo "🔄 Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_ID \
  --paths "/*"

echo "✅ Frontend deployed successfully!"
