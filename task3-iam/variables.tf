variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_a_id" {
  description = "AWS Account A ID."
  type        = string
  default     = "000000000000"
}

variable "account_b_id" {
  description = "AWS Account B ID."
  type        = string
  default     = "111111111111"
}

variable "rolec_bucket_name" {
  description = "The single S3 bucket in Account B that roleC gets full access to."
  type        = string
  default     = "arrise-shared-data-bucket"
}
