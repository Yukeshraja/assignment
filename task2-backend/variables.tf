variable "region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket that stores remote Terraform state. Must be globally unique."
  type        = string
  default     = "arrise-tfstate-000000000000"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
  default     = "arrise-tf-locks"
}
