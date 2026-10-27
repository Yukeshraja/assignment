output "instance_ids" {
  description = "Map of instance name -> instance ID."
  value       = module.ec2_fleet.instance_ids
}

output "instance_private_ips" {
  description = "Map of instance name -> private IP."
  value       = module.ec2_fleet.instance_private_ips
}
