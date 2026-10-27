# Account B (111111111111)

# roleC: full access to one bucket, assumable only by roleB from Account A.
# Trust names roleB's exact ARN (not the Account A root), so nothing else in
# Account A can assume it.
data "aws_iam_policy_document" "roleC_trust" {
  provider = aws.account_b
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
  provider           = aws.account_b
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

data "aws_iam_policy_document" "roleC_permissions" {
  provider = aws.account_b

  statement {
    sid       = "BucketLevel"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.rolec_bucket_name}"]
  }

  statement {
    sid       = "ObjectLevel"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.rolec_bucket_name}/*"]
  }
}

resource "aws_iam_role_policy" "roleC_s3" {
  provider = aws.account_b
  name     = "roleC-s3-access"
  role     = aws_iam_role.roleC.id
  policy   = data.aws_iam_policy_document.roleC_permissions.json
}
