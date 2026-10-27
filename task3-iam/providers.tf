terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Account A (000000000000)
provider "aws" {
  alias  = "account_a"
  region = var.region
  # assume_role {
  #   role_arn = "arn:aws:iam::000000000000:role/terraform-provisioner"
  # }
}

# Account B (111111111111)
provider "aws" {
  alias  = "account_b"
  region = var.region
  # assume_role {
  #   role_arn = "arn:aws:iam::111111111111:role/terraform-provisioner"
  # }
}
