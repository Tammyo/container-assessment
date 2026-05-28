#!/bin/bash
set -e

echo "Deploying frontend to S3..."

S3_BUCKET=$1
CLOUDFRONT_DISTRIBUTION_ID=$2
BUILD_DIR=${3:-"Client/build"}

if [ -z "$S3_BUCKET" ] || [ -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo "Usage: ./deploy-frontend.sh <s3-bucket> <cloudfront-distribution-id>"
  exit 1
fi

aws s3 sync $BUILD_DIR s3://$S3_BUCKET \
  --delete \
  --cache-control "max-age=31536000" \
  --exclude "index.html"

aws s3 cp $BUILD_DIR/index.html s3://$S3_BUCKET/index.html \
  --cache-control "no-cache"

aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
  --paths "/*"

echo "Frontend deployment complete!"
