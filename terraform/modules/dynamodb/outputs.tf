output "status_table_name" {
  description = "Name of the RSS status DynamoDB table"
  value       = aws_dynamodb_table.status_table.name
}

output "status_table_arn" {
  description = "ARN of the RSS status DynamoDB table"
  value       = aws_dynamodb_table.status_table.arn
}

output "status_table_id" {
  description = "ID of the RSS status DynamoDB table"
  value       = aws_dynamodb_table.status_table.id
}

output "sent_table_name" {
  description = "Name of the sent items DynamoDB table"
  value       = aws_dynamodb_table.sent_table.name
}

output "sent_table_arn" {
  description = "ARN of the sent items DynamoDB table"
  value       = aws_dynamodb_table.sent_table.arn
}

output "sent_table_id" {
  description = "ID of the sent items DynamoDB table"
  value       = aws_dynamodb_table.sent_table.id
}