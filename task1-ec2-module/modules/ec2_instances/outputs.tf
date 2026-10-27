locals {
  all_instances = merge(
    { for k, v in aws_instance.this : k => v },
    { for k, v in aws_instance.protected : k => v },
  )
}

output "instance_ids" {
  description = "instance name -> instance ID"
  value       = { for k, v in local.all_instances : v.tags["Name"] => v.id }
}

output "instance_private_ips" {
  description = "instance name -> private IP"
  value       = { for k, v in local.all_instances : v.tags["Name"] => v.private_ip }
}
