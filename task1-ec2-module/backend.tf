# Remote state in S3 with DynamoDB locking.
# Bucket and table must exist first (see ../task2-backend). Run terraform init
# to migrate local state over.
terraform {
  backend "s3" {
    bucket         = "arrise-tfstate-000000000000"
    key            = "task1-ec2-module/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "arrise-tf-locks"
    encrypt        = true
  }
}
