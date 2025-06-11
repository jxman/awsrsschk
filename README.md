# AWS RSS Status Checker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange.svg)](https://aws.amazon.com/lambda/)
[![Terraform](https://img.shields.io/badge/Infrastructure-Terraform-623CE4.svg)](https://www.terraform.io/)
[![DynamoDB](https://img.shields.io/badge/AWS-DynamoDB-blue.svg)](https://aws.amazon.com/dynamodb/)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/your-username/aws-serverless-rss-checker/graphs/commit-activity)
[![Security](https://img.shields.io/badge/security-updated-brightgreen.svg)]()

🚨 **Enterprise-grade serverless RSS monitoring application** that tracks cloud service status updates and sends real-time notifications to Microsoft Teams. Built with **Infrastructure as Code** using Terraform for production-ready deployments.

## 🌟 Features

- **Infrastructure as Code**: Complete Terraform modules for AWS deployment
- **Multi-Environment Support**: Separate dev/staging/prod configurations
- **Multi-Provider Monitoring**: Track status from AWS, Azure, CloudFlare, GitHub, and more
- **Real-Time Notifications**: Instant Microsoft Teams alerts with rich formatting
- **Duplicate Prevention**: Smart filtering with DynamoDB deduplication and TTL cleanup
- **Serverless Architecture**: Cost-effective AWS Lambda with auto-scaling
- **Automatic Scheduling**: Configurable polling intervals with EventBridge
- **Comprehensive Monitoring**: CloudWatch dashboards, alarms, and structured logging
- **Error Resilience**: Retry logic, graceful failure handling, and comprehensive error reporting
- **Security First**: IAM least privilege, encryption at rest, and secure credential management
- **Cost Optimization**: Reserved concurrency, on-demand billing, and automatic cleanup

## 🏗️ Architecture

### System Overview
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  External RSS   │    │   EventBridge   │    │   AWS Lambda    │
│    Sources      │───▶│   (Scheduler)   │───▶│  RSS Checker    │
│ (AWS, Azure, etc)│    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────┬───────────┘
                                                     │
┌─────────────────┐    ┌─────────────────┐          │
│ Microsoft Teams │◀───│   CloudWatch    │◀─────────┤
│   (Webhooks)    │    │ Logs & Metrics  │          │
└─────────────────┘    └─────────────────┘          │
                                                     │
┌─────────────────┐    ┌─────────────────┐          │
│    DynamoDB     │◀───│    DynamoDB     │◀─────────┘
│  Status Table   │    │  Sent Items     │
│                 │    │   (TTL Auto     │
│                 │    │    Cleanup)     │
└─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   IAM Role      │
                       │  (Least         │
                       │  Privilege)     │
                       └─────────────────┘
```

### Data Flow
1. **EventBridge** triggers Lambda on schedule (10 minutes default)
2. **Lambda** scans DynamoDB for RSS sources to monitor
3. **RSS Feeds** are fetched and parsed from external services
4. **New items** are detected using DynamoDB deduplication
5. **Notifications** are sent to Microsoft Teams via webhooks
6. **Logs** are captured in CloudWatch for monitoring
7. **Cleanup** happens automatically via DynamoDB TTL

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
├── 📁 terraform/                 # Infrastructure as Code
│   ├── main.tf                  # Core infrastructure
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Resource outputs
│   ├── backend.tf               # Remote state configuration
│   ├── 📁 modules/              # Reusable Terraform modules
│   │   ├── lambda/              # Lambda function module
│   │   └── dynamodb/            # DynamoDB tables module
│   ├── 📁 environments/         # Environment-specific configs
│   │   ├── dev/terraform.tfvars
│   │   └── prod/terraform.tfvars
│   ├── README.md                # Terraform documentation
│   └── architecture-diagram.svg # Visual architecture diagram
├── 📁 env/                       # Environment configuration
│   ├── .gitkeep                 # Preserves directory in git
│   └── env.template.json        # Configuration template
├── 📄 serverless.yml            # Legacy Serverless Framework config
├── 📄 package.json              # Dependencies and scripts
├── 📄 deploy.sh                 # Automated deployment script
├── 📄 .gitignore                # Comprehensive ignore patterns
└── 📄 README.md                 # This documentation
```

## 🚀 Quick Start

### Prerequisites

- **Node.js 18+** and npm
- **AWS CLI** configured with appropriate permissions
- **Terraform** >= 1.0 installed
- **Microsoft Teams** webhook URL

### Installation & Deployment

#### Option 1: Terraform (Recommended)

1. **Clone and setup**:
   ```bash
   git clone <your-repo-url>
   cd aws-serverless-rss-checker
   npm install
   ```

2. **Configure Terraform backend** (optional but recommended):
   ```bash
   # Create S3 bucket for state storage
   aws s3 mb s3://your-terraform-state-bucket-name
   
   # Enable versioning
   aws s3api put-bucket-versioning \
     --bucket your-terraform-state-bucket-name \
     --versioning-configuration Status=Enabled
   
   # Create DynamoDB table for state locking
   aws dynamodb create-table \
     --table-name terraform-state-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

3. **Configure environment**:
   ```bash
   cd terraform
   
   # Copy and edit development configuration
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   # Edit the file with your actual values:
   # - teams_webhook_url
   # - aws_region
   # - any other customizations
   ```

4. **Deploy infrastructure**:
   ```bash
   # Initialize Terraform
   terraform init
   
   # Plan deployment (review changes)
   terraform plan -var-file="environments/dev/terraform.tfvars"
   
   # Deploy to development
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

5. **Add RSS sources to DynamoDB**:
   ```bash
   # AWS Status Feed
   aws dynamodb put-item \
     --table-name awsrss-status-dev \
     --item '{
       "statusId": {"S": "AWS"},
       "rssUrl": {"S": "https://status.aws.amazon.com/rss/all.rss"}
     }'
   ```

6. **Test deployment**:
   ```bash
   # Invoke Lambda function directly
   aws lambda invoke \
     --function-name awsrss-dev-rss-checker \
     --payload '{}' \
     response.json
   
   # View logs
   aws logs tail /aws/lambda/awsrss-dev-rss-checker --follow
   ```

#### Option 2: Serverless Framework (Legacy)

1. **Setup and configure**:
   ```bash
   npm install -g serverless
   cp env/env.template.json env/env.dev.json
   # Edit env/env.dev.json with your actual values
   ```

2. **Deploy**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh dev us-east-1
   ```

## ⚙️ Configuration

### Terraform Variables

Edit `terraform/environments/dev/terraform.tfvars` or `terraform/environments/prod/terraform.tfvars`:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `teams_webhook_url` | Microsoft Teams webhook URL | `https://...webhook.office.com/...` | Yes |
| `teams_test_webhook_url` | Test webhook URL | `https://...webhook.office.com/...` | No |
| `environment` | Environment name | `dev`, `prod` | Yes |
| `aws_region` | AWS deployment region | `us-east-1` | Yes |
| `enable_scheduler` | Enable automatic execution | `true`, `false` | No |
| `schedule_expression` | EventBridge schedule | `rate(10 minutes)` | No |
| `lambda_timeout` | Function timeout (seconds) | `60` | No |
| `lambda_memory_size` | Memory allocation (MB) | `512` | No |
| `log_retention_days` | CloudWatch log retention | `14` | No |

### RSS Feed Sources

Popular RSS feeds to monitor (automatically added to DynamoDB):

| Service | URL | Description |
|---------|-----|-------------|
| AWS | https://status.aws.amazon.com/rss/all.rss | Amazon Web Services |
| Azure | https://azurestatuscdn.azureedge.net/en-us/status/feed/ | Microsoft Azure |
| CloudFlare | https://www.cloudflarestatus.com/history.rss | Cloudflare CDN |
| GitHub | https://www.githubstatus.com/history.rss | GitHub Platform |
| Datadog | https://status.datadoghq.com/history.rss | Datadog Monitoring |
| Heroku | https://status.heroku.com/feed | Heroku Platform |
| Stripe | https://status.stripe.com/history.rss | Stripe Payments |
| Atlassian | https://status.atlassian.com/history.rss | Atlassian Services |

## 🗄️ Infrastructure Details

### AWS Resources Created

#### Core Services
- **AWS Lambda**: RSS processing function with 512MB memory, 60s timeout
- **DynamoDB Tables**: 
  - Status table (RSS sources configuration)
  - Sent items table (duplicate tracking with TTL)
- **CloudWatch Log Group**: Function logs with configurable retention
- **IAM Role**: Least privilege execution role
- **EventBridge Rule**: Optional scheduled triggers

#### Security Features
- **IAM Least Privilege**: Minimal required permissions for Lambda
- **DynamoDB Encryption**: Server-side encryption enabled
- **VPC Support**: Can be deployed in VPC (commented configuration)
- **Resource Tagging**: Comprehensive tagging strategy for cost tracking

#### Cost Optimization
- **On-Demand Billing**: DynamoDB pay-per-request pricing
- **Reserved Concurrency**: Lambda concurrency limited to 2
- **TTL Cleanup**: Automatic data cleanup (7 days dev, 30 days prod)
- **Log Retention**: Configurable CloudWatch log retention

### Database Schema

#### Status Table
- **Partition Key**: `statusId` (String) - Unique RSS source identifier
- **Attributes**: `rssUrl` (String) - RSS feed URL to monitor

#### Sent Items Table  
- **Partition Key**: `guidItem` (String) - RSS item GUID
- **Attributes**:
  - `latestDate` (String) - Publication date
  - `statusId` (String) - Source identifier
  - `sentDate` (String) - Notification timestamp
  - `ttl` (Number) - Auto-cleanup timestamp

## 🚀 Deployment Options

### Development Environment
```bash
cd terraform
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Production Environment
```bash
# Configure production variables
cp environments/dev/terraform.tfvars environments/prod/terraform.tfvars
# Edit prod/terraform.tfvars with production settings

# Deploy to production
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### Multi-Region Deployment
```bash
# Deploy to multiple regions
terraform apply -var-file="environments/prod/terraform.tfvars" -var="aws_region=us-west-2"
terraform apply -var-file="environments/prod/terraform.tfvars" -var="aws_region=eu-west-1"
```

## 📊 Monitoring & Operations

### CloudWatch Dashboards
Access monitoring through AWS Console:
- Lambda execution metrics and duration
- Error rates and success rates  
- DynamoDB read/write capacity and throttling
- Custom application metrics

### Logging & Debugging
```bash
# Real-time log monitoring
aws logs tail /aws/lambda/awsrss-dev-rss-checker --follow

# Search error logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/awsrss-dev-rss-checker \
  --filter-pattern "ERROR"

# Get function configuration
aws lambda get-function-configuration \
  --function-name awsrss-dev-rss-checker
```

### Performance Metrics
- **Target Execution Time**: < 30 seconds
- **Error Rate**: < 1%
- **Memory Usage**: Optimized for 512MB
- **Concurrent Executions**: Limited to 2

## 🧪 Testing & Validation

### Infrastructure Testing
```bash
# Validate Terraform configuration
terraform validate

# Plan without applying
terraform plan -var-file="environments/dev/terraform.tfvars"

# Test Lambda function
aws lambda invoke \
  --function-name awsrss-dev-rss-checker \
  --payload '{}' \
  response.json && cat response.json
```

### Application Testing
```bash
# Test DynamoDB connectivity
aws dynamodb scan --table-name awsrss-status-dev --limit 1

# Validate webhook URL
curl -X POST "$TEAMS_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text": "Test notification from RSS Checker"}'

# Test RSS feed accessibility
curl -I "https://status.aws.amazon.com/rss/all.rss"
```

## 🚨 Troubleshooting

### Common Infrastructure Issues

#### 1. Terraform State Issues
```bash
# Problem: State file conflicts
# Solution: Configure remote state backend
terraform init -backend-config="bucket=your-state-bucket"
```

#### 2. Permission Errors
```bash
# Problem: IAM permission denied
# Solution: Verify AWS credentials and policies
aws sts get-caller-identity
terraform plan # Will show specific permission issues
```

#### 3. Resource Conflicts
```bash
# Problem: Resource already exists
# Solution: Import existing resources or use different names
terraform import aws_dynamodb_table.status_table awsrss-status-dev
```

### Application Issues

#### 1. Lambda Timeout
```bash
# Problem: Function exceeds timeout
# Solution: Increase timeout in terraform/variables.tf
variable "lambda_timeout" {
  default = 120  # Increase from 60
}
```

#### 2. DynamoDB Throttling
```bash
# Problem: Read/write capacity exceeded
# Solution: Check metrics and consider provisioned billing
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ReadThrottleEvents \
  --dimensions Name=TableName,Value=awsrss-status-dev
```

### Debug Commands
```bash
# Infrastructure status
terraform show
terraform output

# Application logs
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/awsrss"

# Resource inspection
aws lambda list-functions --max-items 20
aws dynamodb list-tables
```

## 🔒 Security & Compliance

### Security Features
- **IAM Least Privilege**: Minimal required permissions only
- **Encryption at Rest**: DynamoDB tables encrypted
- **Encryption in Transit**: All API calls use HTTPS
- **Input Validation**: RSS content sanitized before processing
- **Error Sanitization**: No sensitive data in error messages
- **Resource Isolation**: Separate environments and resources

### Compliance Considerations
- **Logging**: All actions logged in CloudWatch
- **Audit Trail**: CloudTrail integration available
- **Data Retention**: Configurable log and data retention
- **Access Control**: IAM-based access management

### Best Practices Implemented
- Secure dependency management
- Regular security updates
- Input sanitization and validation
- Comprehensive error handling
- Infrastructure as Code for consistency

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone <your-fork-url>`
3. Install dependencies: `npm install`
4. Configure Terraform: `cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars`
5. Initialize infrastructure: `cd terraform && terraform init`
6. Create feature branch: `git checkout -b feature/your-feature`

### Infrastructure Changes
- Test changes in development environment first
- Update documentation for any new variables or outputs
- Follow Terraform best practices and formatting
- Include both Terraform and application testing

### Code Standards
- Use ES6+ JavaScript features
- Follow existing error handling patterns
- Include comprehensive logging
- Maintain Infrastructure as Code principles
- Test thoroughly before submitting

## 📊 Architecture Diagram

For a detailed visual representation of the AWS architecture, see:
- **Visual Diagram**: `terraform/architecture-diagram.svg`
- **Terraform Documentation**: `terraform/README.md`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`aws` `terraform` `infrastructure-as-code` `lambda` `serverless` `rss` `monitoring` `nodejs` `dynamodb` `microsoft-teams` `cloudwatch` `status-monitoring` `enterprise` `security` `multi-environment`

---

## 🚀 Quick Commands Reference

```bash
# Infrastructure Setup (Terraform)
cd terraform
terraform init
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"

# Application Testing
aws lambda invoke --function-name awsrss-dev-rss-checker --payload '{}' response.json
aws logs tail /aws/lambda/awsrss-dev-rss-checker --follow

# Infrastructure Management
terraform output
terraform destroy -var-file="environments/dev/terraform.tfvars"

# Legacy Serverless Framework
./deploy.sh dev us-east-1
npx serverless invoke -f main --stage dev
```

---

**Built with ❤️ using Infrastructure as Code for reliable enterprise cloud service monitoring**

### 🌟 Star this repository if it helped you build scalable cloud monitoring infrastructure!