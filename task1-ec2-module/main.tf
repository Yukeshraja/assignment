terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "ec2_fleet" {
  source = "./modules/ec2_instances"

  ami_id      = var.ami_id
  environment = var.environment
  owner       = var.owner
  name_prefix = var.name_prefix

  # web uses io2 and is the protected instance.
  instances = {
    web = {
      instance_type    = "t3.micro"
      root_volume_type = "io2"
      root_volume_size = 50
      key_name         = "web-key"
      iops             = 1000
      protected        = true
    }
    app = {
      instance_type    = "t3.small"
      root_volume_type = "gp3"
      root_volume_size = 30
      key_name         = "app-key"
      iops             = 3000
    }
    worker = {
      instance_type    = "t3.medium"
      root_volume_type = "gp2"
      root_volume_size = 40
      key_name         = "worker-key"
    }
    cache = {
      instance_type    = "t3.large"
      root_volume_type = "gp2"
      root_volume_size = 20
      key_name         = "cache-key"
    }
    batch = {
      instance_type    = "c5.large"
      root_volume_type = "io1"
      root_volume_size = 60
      key_name         = "batch-key"
      iops             = 2000
    }
  }
}
