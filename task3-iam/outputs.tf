output "roleA_arn" {
  description = "ARN of roleA (admin except IAM) in Account A."
  value       = aws_iam_role.roleA.arn
}

output "roleB_arn" {
  description = "ARN of roleB (assume-roleC-only) in Account A."
  value       = aws_iam_role.roleB.arn
}

output "roleC_arn" {
  description = "ARN of roleC (single-bucket S3 access) in Account B."
  value       = aws_iam_role.roleC.arn
}

output "group1_name" {
  value = aws_iam_group.group1.name
}

output "group2_name" {
  value = aws_iam_group.group2.name
}
