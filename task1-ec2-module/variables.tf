variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for all instances. Override with a valid AMI for your region."
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1) - replace as needed
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "platform-team"
}

variable "name_prefix" {
  description = "Prefix for instance Name tags."
  type        = string
  default     = "arrise"
}
