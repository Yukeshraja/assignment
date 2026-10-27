terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# prevent_destroy only takes a literal, so we can't toggle it per for_each key.
# Split the map and give the protected instance its own block.
locals {
  protected_instances   = { for k, v in var.instances : k => v if v.protected }
  unprotected_instances = { for k, v in var.instances : k => v if !v.protected }
}

resource "aws_instance" "this" {
  for_each = local.unprotected_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = contains(["io1", "io2", "gp3"], each.value.root_volume_type) ? each.value.iops : null

    tags = {
      Name        = "${var.name_prefix}-${each.key}-root"
      Environment = var.environment
      Owner       = var.owner
    }
  }

  tags = {
    Name        = "${var.name_prefix}-${each.key}"
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami           = var.ami_id
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = contains(["io1", "io2", "gp3"], each.value.root_volume_type) ? each.value.iops : null

    tags = {
      Name        = "${var.name_prefix}-${each.key}-root"
      Environment = var.environment
      Owner       = var.owner
    }
  }

  tags = {
    Name        = "${var.name_prefix}-${each.key}"
    Environment = var.environment
    Owner       = var.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}
