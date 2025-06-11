# Development Environment Configuration
environment = "dev" 
aws_region  = "us-east-1"

# Lambda Configuration
lambda_timeout         = 60
lambda_memory_size     = 512
lambda_reserved_concurrency = 2

# Notification Configuration (replace with actual webhook URLs)
teams_webhook_url      = "https://your-dev-teams-webhook-url.webhook.office.com/webhookb2/..."
teams_test_webhook_url = "https://your-test-teams-webhook-url.webhook.office.com/webhookb2/..."

# Application Configuration
date_offset = "600000"  # 10 minutes in milliseconds

# DynamoDB Configuration
sent_table_ttl_days = 7

# Monitoring Configuration
log_retention_days = 14

# Scheduler Configuration (disabled by default for dev)
enable_scheduler     = false
schedule_expression  = "rate(10 minutes)"