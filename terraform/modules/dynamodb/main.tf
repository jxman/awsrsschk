# RSS Status Table - stores RSS feed URLs to monitor
resource "aws_dynamodb_table" "status_table" {
  name           = var.status_table_name
  billing_mode   = var.billing_mode
  
  # On-demand billing doesn't require capacity units
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  hash_key = "statusId"

  attribute {
    name = "statusId"
    type = "S"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled = var.enable_encryption
  }

  tags = merge(var.tags, {
    Name        = var.status_table_name
    Purpose     = "RSS-Feed-Configuration"
    TableType   = "Status"
  })
}

# Sent Items Table - tracks processed RSS items to prevent duplicates
resource "aws_dynamodb_table" "sent_table" {
  name           = var.sent_table_name
  billing_mode   = var.billing_mode
  
  # On-demand billing doesn't require capacity units
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  hash_key = "guidItem"

  attribute {
    name = "guidItem"
    type = "S"
  }

  # TTL configuration for automatic cleanup
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled = var.enable_encryption
  }

  tags = merge(var.tags, {
    Name        = var.sent_table_name
    Purpose     = "RSS-Item-Tracking"
    TableType   = "Sent"
  })
}