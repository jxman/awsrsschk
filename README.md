# AWS RSS Status Checker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange.svg)](https://aws.amazon.com/lambda/)
[![Serverless Framework](https://img.shields.io/badge/Serverless-Framework-fd5750.svg)](https://www.serverless.com/)
[![DynamoDB](https://img.shields.io/badge/AWS-DynamoDB-blue.svg)](https://aws.amazon.com/dynamodb/)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/your-username/aws-serverless-rss-checker/graphs/commit-activity)
[![Dependencies](https://img.shields.io/badge/dependencies-up%20to%20date-brightgreen.svg)]()
[![Security](https://img.shields.io/badge/security-updated-brightgreen.svg)]()
[![Code Style](https://img.shields.io/badge/code%20style-standard-brightgreen.svg)](https://standardjs.com)

🚨 **Enterprise-grade serverless RSS monitoring application** that tracks cloud service status updates and sends real-time notifications to Microsoft Teams with comprehensive security and reliability features.

## 🌟 Features

- **Multi-Provider Monitoring**: Track status from AWS, Azure, CloudFlare, GitHub, and more
- **Real-Time Notifications**: Instant Microsoft Teams alerts with rich card formatting
- **Duplicate Prevention**: Smart filtering with DynamoDB deduplication
- **Serverless Architecture**: Cost-effective AWS Lambda with auto-scaling
- **Automatic Scheduling**: Configurable polling intervals with EventBridge
- **Comprehensive Monitoring**: CloudWatch dashboards, alarms, and structured logging
- **Error Resilience**: Retry logic, graceful failure handling, and comprehensive error reporting
- **Security First**: Input validation, content sanitization, and secure credential management
- **Developer Experience**: Professional tooling, templates, and automated deployment

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   EventBridge   │───▶│    Lambda    │───▶│   DynamoDB      │
│   (Scheduler)   │    │ RSS Checker  │    │  (Status DB)    │
└─────────────────┘    └──────┬───────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│ Microsoft Teams │◀───│  RSS Feeds   │    │   DynamoDB      │
│   (Webhooks)    │    │  Processing  │───▶│   (Sent DB)     │
└─────────────────┘    └──────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │  CloudWatch  │
                       │ Monitoring   │
                       └──────────────┘
```

## 📁 Project Structure

```
aws-serverless-rss-checker/
├── 📄 handler.js                 # Main Lambda function handler
├── 📁 lib/                       # Core application modules
│   ├── checkrss.js              # RSS feed parsing logic
│   ├── loopfeed.js              # Feed item processing
│   ├── webhook.js               # Microsoft Teams notifications
│   ├── dynamoget.js             # DynamoDB read operations
│   └── dynamoput.js             # DynamoDB write operations
├── 📁 env/                       # Environment configuration
│   ├── .gitkeep                 # Preserves directory in git
│   └── env.template.json        # Configuration template
├── 📁 .vscode/                   # Development environment
│   ├── extensions.json          # Recommended VSCode extensions
│   └── settings.json.template   # IDE settings template
├── 📄 serverless.yml            # Infrastructure as Code
├── 📄 package.json              # Dependencies and scripts
├── 📄 deploy.sh                 # Automated deployment script
├── 📄 .gitignore                # Comprehensive ignore patterns
└── 📄 README.md                 # This documentation
```

## 🚀 Quick Start

### Prerequisites

- **Node.js 18+** and npm
- **AWS CLI** configured with appropriate permissions
- **Serverless Framework** CLI (`npm install -g serverless`)
- **Microsoft Teams** webhook URL

### Installation

1. **Clone and setup**:
   ```bash
   git clone <your-repo-url>
   cd aws-serverless-rss-checker
   npm install
   ```

2. **Configure environment**:
   ```bash
   # Copy template and configure for development
   cp env/env.template.json env/env.dev.json
   
   # Edit env/env.dev.json with your actual values:
   # - Replace YOUR-ACCOUNT-ID with your AWS account ID
   # - Add your Microsoft Teams webhook URL
   # - Configure DynamoDB table names and ARNs
   ```

3. **Create DynamoDB tables** (see Database Setup section below)

4. **Deploy**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh dev us-east-1
   ```

5. **Test deployment**:
   ```bash
   npx serverless invoke -f main --stage dev
   npx serverless logs -f main --stage dev --tail
   ```

## ⚙️ Configuration

### Environment Variables

Create `env/env.dev.json` and `env/env.prod.json` based on the template:

| Variable | Description | Example |
|----------|-------------|---------|
| `ENVIRONMENT` | Deployment stage | `DEV`, `PROD` |
| `PROD_HOOK` | Microsoft Teams webhook URL | `https://...webhook.office.com/...` |
| `TEST_HOOK` | Test webhook URL (optional) | `https://...webhook.office.com/...` |
| `DYNAMO_TABLE` | RSS sources table name | `awsrss-status-dev` |
| `DYNAMO_SENT` | Processed items table name | `awsrss-sent-dev` |
| `DATE_OFFSET` | Time window in milliseconds | `600000` (10 minutes) |
| `ARN_STATUS` | DynamoDB table ARN for sources | `arn:aws:dynamodb:...` |
| `ARN_SENT` | DynamoDB table ARN for tracking | `arn:aws:dynamodb:...` |
| `AWS_REGION` | AWS deployment region | `us-east-1` |

### RSS Feed Sources

Popular RSS feeds to monitor (add to `DYNAMO_TABLE` DynamoDB table):

| statusId | rssUrl | Description |
|----------|--------|-------------|
| AWS | https://status.aws.amazon.com/rss/all.rss | Amazon Web Services |
| Azure | https://azurestatuscdn.azureedge.net/en-us/status/feed/ | Microsoft Azure |
| CloudFlare | https://www.cloudflarestatus.com/history.rss | Cloudflare CDN |
| GitHub | https://www.githubstatus.com/history.rss | GitHub Platform |
| Datadog | https://status.datadoghq.com/history.rss | Datadog Monitoring |
| Heroku | https://status.heroku.com/feed | Heroku Platform |
| Stripe | https://status.stripe.com/history.rss | Stripe Payments |
| Atlassian | https://status.atlassian.com/history.rss | Atlassian Services |
| Salesforce | https://status.salesforce.com/instances/na1/history.rss | Salesforce CRM |

## 🗄️ Database Setup

### Create DynamoDB Tables

#### Status Sources Table
```bash
aws dynamodb create-table \
  --table-name awsrss-status-dev \
  --attribute-definitions AttributeName=statusId,AttributeType=S \
  --key-schema AttributeName=statusId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Project,Value=AwsRssChecker Key=Environment,Value=dev
```

#### Sent Items Tracking Table
```bash
aws dynamodb create-table \
  --table-name awsrss-sent-dev \
  --attribute-definitions AttributeName=guidItem,AttributeType=S \
  --key-schema AttributeName=guidItem,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Project,Value=AwsRssChecker Key=Environment,Value=dev
```

### Database Schema

#### Status Table (`DYNAMO_TABLE`)
- **Partition Key**: `statusId` (String) - Unique identifier for RSS source
- **Attributes**: 
  - `rssUrl` (String) - RSS feed URL to monitor

#### Sent Table (`DYNAMO_SENT`)
- **Partition Key**: `guidItem` (String) - RSS item GUID
- **Attributes**:
  - `latestDate` (String) - Publication date
  - `statusId` (String) - Source identifier  
  - `sentDate` (String) - When notification was sent
  - `ttl` (Number) - Auto-cleanup timestamp

### Sample Data

Add RSS sources to your status table:

```bash
# AWS Status Feed
aws dynamodb put-item \
  --table-name awsrss-status-dev \
  --item '{
    "statusId": {"S": "AWS"},
    "rssUrl": {"S": "https://status.aws.amazon.com/rss/all.rss"}
  }'

# GitHub Status Feed  
aws dynamodb put-item \
  --table-name awsrss-status-dev \
  --item '{
    "statusId": {"S": "GitHub"},
    "rssUrl": {"S": "https://www.githubstatus.com/history.rss"}
  }'
```

## 🚀 Deployment

### Development Environment
```bash
# Deploy to development
./deploy.sh dev us-east-1

# Or manually
npx serverless deploy --stage dev --region us-east-1
```

### Production Environment
```bash
# Ensure env/env.prod.json is configured
cp env/env.template.json env/env.prod.json
# Edit env/env.prod.json with production values

# Deploy to production
./deploy.sh prod us-east-1
```

### Enable Scheduled Execution
Uncomment the events section in `serverless.yml`:
```yaml
events:
  - schedule:
      rate: rate(10 minutes)
      enabled: true
```

## 📊 Monitoring & Observability

### CloudWatch Dashboards
Access monitoring dashboards in AWS Console:
- Lambda execution metrics and duration
- Error rates and success rates
- DynamoDB read/write capacity and throttling
- Custom application metrics

### Structured Logging
```bash
# Real-time log tailing
npx serverless logs -f main --stage dev --tail

# Filter specific logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/awsrss-backend-dev-rss-checker \
  --filter-pattern "ERROR"

# Search by time range
aws logs filter-log-events \
  --log-group-name /aws/lambda/awsrss-backend-dev-rss-checker \
  --start-time $(date -d '1 hour ago' +%s)000
```

### Performance Metrics
- **Target Execution Time**: < 30 seconds
- **Error Rate**: < 1%
- **Memory Usage**: Optimized for 512MB
- **Concurrent Executions**: Limited to 2 (prevents API overwhelming)

## 🔧 Development

### VSCode Setup (Recommended)
```bash
# Copy VSCode settings template
cp .vscode/settings.json.template .vscode/settings.json

# Install recommended extensions (VSCode will prompt)
# Extensions include: AWS Toolkit, YAML support, ESLint integration
```

### Local Development
```bash
# Install Serverless Offline for local testing
npm install -g serverless-offline

# Run locally (when configured)
npx serverless offline start
```

### Code Quality
```bash
npm run lint                # Code linting
npm test                   # Run tests
npm run deploy:dev         # Deploy to development
npm run logs              # View logs
```

## 🧪 Testing

### Manual Testing
```bash
# Test Lambda function directly
npx serverless invoke -f main --stage dev

# Test with custom payload
echo '{}' | npx serverless invoke -f main --stage dev --data
```

### Validation Scripts
```bash
# Check environment configuration
node -e "console.log(JSON.stringify(require('./env/env.dev.json'), null, 2))"

# Test DynamoDB connectivity
aws dynamodb scan --table-name awsrss-status-dev --limit 1

# Validate webhook URL
curl -X POST "$PROD_HOOK" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test notification from RSS Checker"}'
```

## 🚨 Troubleshooting

### Common Issues & Solutions

#### 1. Environment Configuration Errors
```bash
# Problem: Environment file not found
# Solution: Copy template and configure
cp env/env.template.json env/env.dev.json
# Edit the file with your actual values
```

#### 2. DynamoDB Permission Errors
```bash
# Problem: AccessDenied on DynamoDB operations
# Solution: Verify IAM permissions and table ARNs
aws iam get-role --role-name awsrss-backend-dev-us-east-1-lambdaRole
```

#### 3. Webhook Delivery Failures
```bash
# Problem: Teams notifications not working
# Solution: Test webhook URL manually
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test message"}'
```

#### 4. RSS Parsing Errors
```bash
# Problem: Feed parsing failures
# Solution: Test RSS feed accessibility
curl -I "https://status.aws.amazon.com/rss/all.rss"
```

### Debug Commands
```bash
# View Lambda configuration
aws lambda get-function-configuration \
  --function-name awsrss-backend-dev-rss-checker

# Check CloudWatch logs
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/awsrss-backend"

# Test DynamoDB table access
aws dynamodb describe-table --table-name awsrss-status-dev
```

## 🔒 Security Features

### Data Protection
- **Environment Variables**: Sensitive configuration secured
- **Input Validation**: RSS content sanitized before processing
- **Content Limits**: Message size limits prevent Teams API issues
- **Error Sanitization**: No sensitive data in error messages

### AWS Security
- **IAM Least Privilege**: Minimal required permissions
- **VPC Deployment**: Optional VPC isolation
- **Encryption**: Data encrypted at rest and in transit
- **Access Logging**: CloudTrail integration

### Best Practices Implemented
- Secure dependency management
- Regular security updates
- Input sanitization
- Error handling without data leakage

## 📈 Performance Optimizations

### Lambda Configuration
- **Runtime**: Node.js 20.x (latest LTS)
- **Memory**: 512 MB (optimized for RSS parsing)
- **Timeout**: 60 seconds (allows for slow RSS feeds)
- **Reserved Concurrency**: 2 (prevents API rate limiting)

### Efficiency Features
- **Connection Reuse**: AWS SDK connection pooling
- **Consistent Reads**: DynamoDB data accuracy
- **Efficient Queries**: Optimized database operations
- **Smart Caching**: Duplicate prevention logic

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone <your-fork-url>`
3. Install dependencies: `npm install`
4. Copy environment template: `cp env/env.template.json env/env.dev.json`
5. Configure your development environment
6. Create feature branch: `git checkout -b feature/your-feature`

### Contribution Guidelines
- Follow existing code style and structure
- Add tests for new functionality
- Update documentation for changes
- Test thoroughly in development environment
- Submit pull request with clear description

### Code Standards
- Use ES6+ JavaScript features
- Follow existing error handling patterns
- Include comprehensive logging
- Maintain backward compatibility

## 📊 Project Statistics

![GitHub repo size](https://img.shields.io/github/repo-size/your-username/aws-serverless-rss-checker)
![GitHub last commit](https://img.shields.io/github/last-commit/your-username/aws-serverless-rss-checker)
![GitHub issues](https://img.shields.io/github/issues/your-username/aws-serverless-rss-checker)
![GitHub pull requests](https://img.shields.io/github/issues-pr/your-username/aws-serverless-rss-checker)

## 🙋‍♂️ Support & Resources

### Documentation
- **Setup Guide**: This README
- **API Documentation**: Inline code comments
- **Architecture**: See diagrams above
- **Troubleshooting**: See troubleshooting section

### Community
- **Issues**: [GitHub Issues](https://github.com/your-username/aws-serverless-rss-checker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/aws-serverless-rss-checker/discussions)
- **Wiki**: [Project Wiki](https://github.com/your-username/aws-serverless-rss-checker/wiki)

### Monitoring
- **CloudWatch**: Lambda and DynamoDB metrics
- **X-Ray**: Distributed tracing (when enabled)
- **CloudTrail**: API call logging

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`aws` `lambda` `serverless` `rss` `monitoring` `nodejs` `dynamodb` `microsoft-teams` `cloudwatch` `status-monitoring` `enterprise` `security` `reliability`

---

## 🚀 Quick Commands Reference

```bash
# Setup
cp env/env.template.json env/env.dev.json
npm install
chmod +x deploy.sh

# Deploy
./deploy.sh dev us-east-1

# Test
npx serverless invoke -f main --stage dev
npx serverless logs -f main --stage dev --tail

# Monitor
aws logs filter-log-events --log-group-name /aws/lambda/awsrss-backend-dev-rss-checker
```

---

**Made with ❤️ for reliable enterprise cloud service monitoring**

### 🌟 Star this repository if it helped you monitor your cloud services!
