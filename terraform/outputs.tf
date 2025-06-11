# Lambda Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.lambda.function_invoke_arn
}

# DynamoDB Outputs
output "status_table_name" {
  description = "Name of the RSS status DynamoDB table"
  value       = module.dynamodb.status_table_name
}

output "status_table_arn" {
  description = "ARN of the RSS status DynamoDB table"
  value       = module.dynamodb.status_table_arn
}

output "sent_table_name" {
  description = "Name of the sent items DynamoDB table"
  value       = module.dynamodb.sent_table_name
}

output "sent_table_arn" {
  description = "ARN of the sent items DynamoDB table"
  value       = module.dynamodb.sent_table_arn
}

# CloudWatch Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

# Scheduler Outputs (when enabled)
output "schedule_rule_name" {
  description = "Name of the EventBridge schedule rule"
  value       = var.enable_scheduler ? aws_cloudwatch_event_rule.rss_schedule[0].name : null
}

output "schedule_rule_arn" {
  description = "ARN of the EventBridge schedule rule"
  value       = var.enable_scheduler ? aws_cloudwatch_event_rule.rss_schedule[0].arn : null
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}