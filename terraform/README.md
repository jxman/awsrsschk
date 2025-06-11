# AWS RSS Status Checker - Terraform Infrastructure

This directory contains the Terraform infrastructure code for the AWS RSS Status Checker application.

## Architecture Overview

The infrastructure consists of:
- **AWS Lambda** - Serverless function for RSS parsing and processing
- **Amazon DynamoDB** - Two tables for RSS feed configuration and processed item tracking
- **Amazon CloudWatch** - Logging and monitoring
- **Amazon EventBridge** - Optional scheduled execution
- **IAM Roles & Policies** - Secure access permissions

## Project Structure

```
terraform/
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── backend.tf             # Remote state configuration
├── modules/
│   ├── lambda/            # Lambda function module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dynamodb/          # DynamoDB tables module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/
    │   └── terraform.tfvars
    └── prod/
        └── terraform.tfvars
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **S3 bucket** for remote state storage (see backend.tf)
4. **Microsoft Teams webhook URLs** for notifications

## Quick Start

### 1. Configure Backend (Optional)

Edit `backend.tf` to configure remote state storage:

```bash
# Create S3 bucket for state
aws s3 mb s3://your-terraform-state-bucket-name

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket-name \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Configure Environment Variables

Edit the appropriate tfvars file:

```bash
# For development
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
vi environments/dev/terraform.tfvars

# For production  
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
vi environments/prod/terraform.tfvars
```

### 4. Deploy Infrastructure

```bash
# Development environment
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"

# Production environment
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `teams_webhook_url` | Microsoft Teams webhook URL | `https://outlook.office.com/...` |
| `environment` | Environment name | `dev`, `prod` |
| `aws_region` | AWS region | `us-east-1` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_scheduler` | `false` | Enable automatic execution |
| `schedule_expression` | `rate(10 minutes)` | EventBridge schedule |
| `lambda_timeout` | `60` | Function timeout (seconds) |
| `lambda_memory_size` | `512` | Memory allocation (MB) |
| `log_retention_days` | `14` | CloudWatch log retention |

## Usage

### Manual Invocation

```bash
# Invoke Lambda function directly
aws lambda invoke \
  --function-name awsrss-dev-rss-checker \
  --payload '{}' \
  response.json

# View response
cat response.json
```

### View Logs

```bash
# Get recent logs
aws logs tail /aws/lambda/awsrss-dev-rss-checker --follow
```

### DynamoDB Management

```bash
# Add RSS feed to monitor
aws dynamodb put-item \
  --table-name awsrss-status-dev \
  --item '{
    "statusId": {"S": "aws-health"},
    "rssUrl": {"S": "https://status.aws.amazon.com/rss/all.rss"}
  }'

# List configured feeds
aws dynamodb scan --table-name awsrss-status-dev
```

## Monitoring

The infrastructure includes comprehensive monitoring:

- **CloudWatch Logs** - Function execution logs with configurable retention
- **CloudWatch Metrics** - Lambda performance metrics
- **DynamoDB Metrics** - Table performance and usage
- **Error Alerting** - Built-in error handling and logging

## Security Features

- **IAM Least Privilege** - Minimal required permissions
- **Encryption at Rest** - DynamoDB tables encrypted
- **Secrets Management** - Sensitive webhook URLs marked as sensitive
- **VPC Support** - Can be deployed in VPC if needed (not enabled by default)

## Cost Optimization

- **On-Demand Billing** - DynamoDB uses pay-per-request pricing
- **Reserved Concurrency** - Lambda concurrency limited to prevent cost spikes
- **Log Retention** - Configurable CloudWatch log retention
- **TTL Cleanup** - Automatic cleanup of old processed items

## Troubleshooting

### Common Issues

1. **Deployment Package Too Large**
   - Check excluded files in `main.tf` archive configuration
   - Ensure `node_modules` are properly excluded

2. **Permission Errors**
   - Verify IAM policies in `modules/lambda/main.tf`
   - Check AWS credentials and permissions

3. **DynamoDB Access Issues**
   - Verify table names match environment configuration
   - Check table ARNs in policy statements

### Debug Commands

```bash
# Check Terraform plan
terraform plan -var-file="environments/dev/terraform.tfvars"

# Validate configuration
terraform validate

# Show current state
terraform show

# Debug Lambda function
aws lambda get-function --function-name awsrss-dev-rss-checker
```

## Best Practices

1. **Environment Separation** - Use separate AWS accounts or regions for dev/prod
2. **State Management** - Always use remote state for team collaboration
3. **Version Control** - Tag infrastructure releases
4. **Security** - Regularly rotate webhook URLs and review IAM permissions
5. **Monitoring** - Set up CloudWatch alarms for error rates and execution duration

## Contributing

1. Make changes in a feature branch
2. Test with `terraform plan` 
3. Deploy to dev environment first
4. Create pull request with infrastructure changes documented
5. Deploy to production after approval

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

**Warning**: This will permanently delete all resources including DynamoDB tables and their data.