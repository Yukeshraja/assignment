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

# Least-privilege policy for the ci user: push to one ECR repo, deploy one ECS
# service, read one S3 bucket. iam:PassRole is scoped to the two ECS roles and
# the ecs-tasks service because ECS can't run a task def without being passed
# its roles.
data "aws_iam_policy_document" "ci" {
  statement {
    sid       = "ECRAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushToSpecificRepo"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["arn:aws:ecr:${var.region}:${var.account_id}:repository/${var.ecr_repo_name}"]
  }

  statement {
    sid       = "ECSRegisterTaskDefinition"
    effect    = "Allow"
    actions   = ["ecs:RegisterTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid       = "ECSUpdateSpecificService"
    effect    = "Allow"
    actions   = ["ecs:UpdateService", "ecs:DescribeServices"]
    resources = ["arn:aws:ecs:${var.region}:${var.account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}"]
  }

  statement {
    sid       = "PassExecutionAndTaskRolesToECS"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = var.ecs_passable_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid    = "ReadOnlyArtifactsBucket"
    effect = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.artifacts_bucket_name}",
      "arn:aws:s3:::${var.artifacts_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "ci" {
  name        = "ci-pipeline-least-privilege"
  description = "CI user: ECR push, ECS deploy, S3 read-only artifacts."
  policy      = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_user_policy_attachment" "ci" {
  user       = var.ci_user_name
  policy_arn = aws_iam_policy.ci.arn
}
