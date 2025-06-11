# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a serverless AWS RSS status checker that monitors cloud service status feeds and sends notifications to Microsoft Teams. The application runs on AWS Lambda with DynamoDB for state management.

## Architecture

- **Main Handler**: `handler.js` - Lambda entry point that scans DynamoDB for RSS feeds
- **Core Logic**: `lib/checkrss.js` - RSS parsing using rss-parser library
- **Feed Processing**: `lib/loopfeed.js` - Processes individual RSS items
- **Database Operations**: `lib/dynamoget.js` and `lib/dynamoput.js` - DynamoDB interactions
- **Notifications**: `lib/webhook.js` - Microsoft Teams webhook integration

## Key Dependencies

- `@aws-sdk/client-dynamodb` - AWS DynamoDB client
- `rss-parser` - RSS feed parsing
- `axios` - HTTP requests for webhooks
- `striptags` - HTML content sanitization

## Development Commands

```bash
# Install dependencies
npm install

# Deploy to development
./deploy.sh dev us-east-1

# Deploy to production  
./deploy.sh prod us-east-1

# Test the function
npx serverless invoke -f main --stage dev

# View logs
npx serverless logs -f main --stage dev --tail

# Manual deployment
npx serverless deploy --stage dev --region us-east-1
```

## Environment Configuration

Environment variables are managed through JSON files in the `env/` directory:
- `env.template.json` - Template with placeholder values
- `env.dev.json` - Development configuration (not in git)
- `env.prod.json` - Production configuration (not in git)

Required environment variables:
- `ENVIRONMENT` - Deployment stage (DEV/PROD)
- `PROD_HOOK` - Microsoft Teams webhook URL
- `DYNAMO_TABLE` - RSS sources table name
- `DYNAMO_SENT` - Processed items tracking table
- `DATE_OFFSET` - Time window for processing (milliseconds)
- `ARN_STATUS` and `ARN_SENT` - DynamoDB table ARNs

## Database Schema

**Status Table** (`DYNAMO_TABLE`):
- Partition Key: `statusId` (String)
- Attributes: `rssUrl` (String)

**Sent Table** (`DYNAMO_SENT`):
- Partition Key: `guidItem` (String) 
- Attributes: `latestDate`, `statusId`, `sentDate`, `ttl`

## Deployment Process

1. Ensure environment configuration exists: `cp env/env.template.json env/env.dev.json`
2. Configure actual values in environment files
3. Verify AWS credentials: `aws sts get-caller-identity`
4. Run deployment script: `./deploy.sh dev us-east-1`

## Error Handling

The application implements comprehensive error handling:
- Feed-level errors don't stop processing of other feeds
- Enhanced logging with request IDs and timestamps
- Graceful handling of malformed RSS feeds
- Connection reuse for AWS SDK operations

## Monitoring

- CloudWatch logs with 14-day retention
- Function timeout: 60 seconds
- Memory allocation: 512MB
- Reserved concurrency: 2 (prevents API overwhelming)
- Structured logging throughout the application