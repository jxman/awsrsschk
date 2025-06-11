# Terraform backend configuration
# This file configures remote state storage for team collaboration and state locking

terraform {
  backend "s3" {
    # Replace with your actual S3 bucket name
    bucket = "your-terraform-state-bucket-name"
    
    # State file path - includes environment for separation
    key = "awsrss/terraform.tfstate"
    
    # AWS region where the S3 bucket is located
    region = "us-east-1"
    
    # DynamoDB table for state locking (recommended)
    dynamodb_table = "terraform-state-locks"
    
    # Encrypt state file at rest
    encrypt = true
    
    # Prevent accidental state file deletion
    # versioning should be enabled on the S3 bucket
  }
}

# Example commands to set up the backend infrastructure:
#
# 1. Create S3 bucket for state storage:
#    aws s3 mb s3://your-terraform-state-bucket-name
#
# 2. Enable versioning on the bucket:
#    aws s3api put-bucket-versioning \
#      --bucket your-terraform-state-bucket-name \
#      --versioning-configuration Status=Enabled
#
# 3. Create DynamoDB table for state locking:
#    aws dynamodb create-table \
#      --table-name terraform-state-locks \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST
#
# 4. Initialize Terraform with the backend:
#    terraform init
#
# Note: Remove this file or comment out the backend block for local development