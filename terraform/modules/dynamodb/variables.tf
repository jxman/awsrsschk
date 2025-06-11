variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "status_table_name" {
  description = "Name of the RSS status DynamoDB table"
  type        = string
}

variable "sent_table_name" {
  description = "Name of the sent items DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Read capacity units (only used with PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used with PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "sent_table_ttl_days" {
  description = "TTL for sent items table in days"
  type        = number
  default     = 7
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB tables"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption for DynamoDB tables"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}