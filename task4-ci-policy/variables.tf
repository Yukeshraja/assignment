variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type    = string
  default = "000000000000"
}

variable "ci_user_name" {
  type    = string
  default = "ci"
}

variable "ecr_repo_name" {
  type    = string
  default = "arrise-app"
}

variable "ecs_cluster_name" {
  type    = string
  default = "arrise-cluster"
}

variable "ecs_service_name" {
  type    = string
  default = "arrise-app-service"
}

variable "artifacts_bucket_name" {
  type    = string
  default = "arrise-build-artifacts"
}

variable "ecs_passable_role_arns" {
  description = "Exact ARNs of the ECS task execution role and task role the CI user may pass."
  type        = list(string)
  default = [
    "arn:aws:iam::000000000000:role/arrise-app-task-execution-role",
    "arn:aws:iam::000000000000:role/arrise-app-task-role",
  ]
}
