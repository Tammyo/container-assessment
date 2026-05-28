# StartTech Application

Full-stack application with React frontend and Golang backend.

## GitHub Secrets Required

Add these in GitHub Settings - Secrets - Actions:

- AWS_ACCESS_KEY_ID: AWS access key
- AWS_SECRET_ACCESS_KEY: AWS secret key
- S3_BUCKET_NAME: Frontend S3 bucket name
- CLOUDFRONT_DISTRIBUTION_ID: CloudFront distribution ID
- REACT_APP_API_URL: Backend API URL
- MONGO_URI: MongoDB Atlas connection string
- REDIS_ENDPOINT: ElastiCache Redis endpoint

## Pipelines

### Frontend Pipeline
- Triggers on changes to Client/
- Builds React app, runs tests, deploys to S3, invalidates CloudFront

### Backend Pipeline
- Triggers on changes to Server/
- Runs Go tests, builds Docker image, pushes to ECR, deploys to EC2

## Manual Deployment

Frontend: ./scripts/deploy-frontend.sh bucket-name cloudfront-id

Backend: ./scripts/deploy-backend.sh asg-name image-uri aws-region

Health Check: ./scripts/health-check.sh alb-name

Rollback: ./scripts/rollback.sh asg-name previous-image-uri aws-region
