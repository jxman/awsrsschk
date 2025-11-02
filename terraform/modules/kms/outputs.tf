output "cloudwatch_logs_key_id" {
  description = "ID of the KMS key for CloudWatch Logs encryption"
  value       = aws_kms_key.cloudwatch_logs.id
}

output "cloudwatch_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs encryption"
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "dynamodb_key_id" {
  description = "ID of the KMS key for DynamoDB encryption"
  value       = aws_kms_key.dynamodb.id
}

output "dynamodb_key_arn" {
  description = "ARN of the KMS key for DynamoDB encryption"
  value       = aws_kms_key.dynamodb.arn
}

output "lambda_key_id" {
  description = "ID of the KMS key for Lambda encryption"
  value       = aws_kms_key.lambda.id
}

output "lambda_key_arn" {
  description = "ARN of the KMS key for Lambda encryption"
  value       = aws_kms_key.lambda.arn
}
