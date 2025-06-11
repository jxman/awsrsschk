#!/bin/bash

# Simple deployment script for critical updates
set -e

STAGE=${1:-dev}
REGION=${2:-us-east-1}

echo "🚀 Deploying AWS RSS Checker to $STAGE environment in $REGION"

# Check if environment file exists
ENV_FILE="env/env.${STAGE}.json"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file $ENV_FILE not found!"
    echo "Please ensure your environment configuration exists"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured properly"
    echo "Please run 'aws configure' or set up AWS credentials"
    exit 1
fi

# Install updated dependencies
echo "📦 Installing updated dependencies..."
npm install

# Deploy with Serverless Framework
echo "🚀 Deploying to AWS..."
npx serverless deploy --stage "$STAGE" --region "$REGION" --verbose

echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   • Test the function: npx serverless invoke -f main --stage $STAGE"
echo "   • View logs: npx serverless logs -f main --stage $STAGE --tail" 
echo "   • Monitor in AWS Console: https://${REGION}.console.aws.amazon.com/lambda/"
