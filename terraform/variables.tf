# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "awsrss"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for Lambda function"
  type        = number
  default     = 2
}

# Notification Configuration
variable "teams_webhook_url" {
  description = "Microsoft Teams webhook URL for production notifications"
  type        = string
  sensitive   = true
}

variable "teams_test_webhook_url" {
  description = "Microsoft Teams webhook URL for test notifications"
  type        = string
  sensitive   = true
  default     = ""
}

# Application Configuration
variable "date_offset" {
  description = "Time window for processing RSS items in milliseconds"
  type        = string
  default     = "600000"
}

variable "sent_table_ttl_days" {
  description = "TTL for sent items table in days"
  type        = number
  default     = 7
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
}

# Scheduler Configuration
variable "enable_scheduler" {
  description = "Enable EventBridge scheduler for automatic RSS checking"
  type        = bool
  default     = false
}

variable "schedule_expression" {
  description = "EventBridge schedule expression (e.g., 'rate(10 minutes)')"
  type        = string
  default     = "rate(10 minutes)"
}