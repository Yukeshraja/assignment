# Fixed version. Two changes:
#   1. trust principal: role/roleB instead of user/roleB (roleB is a role).
#   2. permissions: scope s3:* to the one bucket + its objects, not "*".

variable "account_a_id" {
  type    = string
  default = "000000000000"
}

variable "rolec_bucket_name" {
  type    = string
  default = "arrise-shared-data-bucket"
}

data "aws_iam_policy_document" "roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${var.rolec_bucket_name}",
        "arn:aws:s3:::${var.rolec_bucket_name}/*",
      ]
    }]
  })
}
