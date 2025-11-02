terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Service     = "RSS-Status-Checker"
    }
  }
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Data source for current region
data "aws_region" "current" {}

# KMS keys for encryption at rest
module "kms" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name

  tags = {
    Purpose = "Encryption-Keys"
  }
}

# Lambda function deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../"
  output_path = "../dist/awsrss-backend.zip"
  excludes = [
    "terraform",
    "terraform/**",
    "dist",
    "dist/**",
    ".git",
    ".git/**",
    "README.md",
    "*.md",
    "env/env.dev.json",
    "env/env.prod.json",
    ".gitignore",
    "deploy.sh"
  ]
}

# RSS Status Checker Lambda Function
module "lambda" {
  source = "./modules/lambda"

  function_name     = "${var.project_name}-${var.environment}-rss-checker"
  description       = "Monitors RSS feeds for cloud service status updates"
  handler          = "handler.run"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # KMS encryption for environment variables and logs
  kms_key_arn           = module.kms.lambda_key_arn
  cloudwatch_kms_key_id = module.kms.cloudwatch_logs_key_id

  environment_variables = {
    ENVIRONMENT   = upper(var.environment)
    PROD_HOOK     = var.teams_webhook_url
    TEST_HOOK     = var.teams_test_webhook_url
    DYNAMO_TABLE  = module.dynamodb.status_table_name
    DYNAMO_SENT   = module.dynamodb.sent_table_name
    DATE_OFFSET   = var.date_offset
    ARN_STATUS    = module.dynamodb.status_table_arn
    ARN_SENT      = module.dynamodb.sent_table_arn
    AWS_REGION    = data.aws_region.current.name
    AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
  }

  # IAM permissions
  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "dynamodb:Scan"
      ]
      resources = [module.dynamodb.status_table_arn]
    },
    {
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      resources = [module.dynamodb.sent_table_arn]
    },
    {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  ]

  reserved_concurrency = var.lambda_reserved_concurrency

  tags = {
    Purpose = "RSS-Status-Monitor"
  }
}

# DynamoDB Tables
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment

  # Status table configuration
  status_table_name = "${var.project_name}-status-${var.environment}"

  # Sent items table configuration
  sent_table_name = "${var.project_name}-sent-${var.environment}"

  # TTL configuration for sent items (7 days default)
  sent_table_ttl_days = var.sent_table_ttl_days

  # KMS encryption
  kms_key_arn = module.kms.dynamodb_key_arn

  tags = {
    Purpose = "RSS-Status-Storage"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${module.lambda.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.kms.cloudwatch_logs_key_id

  tags = {
    Purpose = "RSS-Status-Logging"
  }
}

# Optional: EventBridge rule for scheduled execution
resource "aws_cloudwatch_event_rule" "rss_schedule" {
  count = var.enable_scheduler ? 1 : 0
  
  name                = "${var.project_name}-${var.environment}-rss-schedule"
  description         = "Triggers RSS checker at regular intervals"
  schedule_expression = var.schedule_expression

  tags = {
    Purpose = "RSS-Status-Scheduler"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.enable_scheduler ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.rss_schedule[0].name
  target_id = "RssCheckerTarget"
  arn       = module.lambda.function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.enable_scheduler ? 1 : 0
  
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "events.amazonaws.com" 
  source_arn    = aws_cloudwatch_event_rule.rss_schedule[0].arn
}