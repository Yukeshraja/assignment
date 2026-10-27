# Account A (000000000000)

# --- users ---
resource "aws_iam_user" "engine" {
  provider = aws.account_a
  name     = "engine"
}

resource "aws_iam_user" "ci" {
  provider = aws.account_a
  name     = "ci"
}

resource "aws_iam_user" "alice" {
  provider = aws.account_a
  name     = "alice"
}

resource "aws_iam_user" "bob" {
  provider = aws.account_a
  name     = "bob"
}

# --- group1: programmatic-only (engine, ci) ---
# Programmatic-only = access keys, no console login profile.
resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1"
}

resource "aws_iam_group_membership" "group1_members" {
  provider = aws.account_a
  name     = "group1-membership"
  group    = aws_iam_group.group1.name
  users    = [aws_iam_user.engine.name, aws_iam_user.ci.name]
}

resource "aws_iam_access_key" "engine" {
  provider = aws.account_a
  user     = aws_iam_user.engine.name
}

resource "aws_iam_access_key" "ci" {
  provider = aws.account_a
  user     = aws_iam_user.ci.name
}

data "aws_iam_policy_document" "group1_baseline" {
  provider = aws.account_a
  statement {
    sid       = "AllowSelfIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity", "iam:GetUser"]
    resources = ["*"]
  }
}

resource "aws_iam_group_policy" "group1_baseline" {
  provider = aws.account_a
  name     = "group1-baseline"
  group    = aws_iam_group.group1.name
  policy   = data.aws_iam_policy_document.group1_baseline.json
}

# --- group2: console + CLI (alice, bob) ---
resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2"
}

resource "aws_iam_group_membership" "group2_members" {
  provider = aws.account_a
  name     = "group2-membership"
  group    = aws_iam_group.group2.name
  users    = [aws_iam_user.alice.name, aws_iam_user.bob.name]
}

resource "aws_iam_group_policy_attachment" "group2_admin" {
  provider   = aws.account_a
  group      = aws_iam_group.group2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_login_profile" "alice" {
  provider                = aws.account_a
  user                    = aws_iam_user.alice.name
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "bob" {
  provider                = aws.account_a
  user                    = aws_iam_user.bob.name
  password_reset_required = true
}

resource "aws_iam_access_key" "alice" {
  provider = aws.account_a
  user     = aws_iam_user.alice.name
}

resource "aws_iam_access_key" "bob" {
  provider = aws.account_a
  user     = aws_iam_user.bob.name
}

# --- roleA: admin on everything except IAM ---
# Allow * then explicit Deny on iam:* (Deny wins).
data "aws_iam_policy_document" "roleA_trust" {
  provider = aws.account_a
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "roleA" {
  provider           = aws.account_a
  name               = "roleA"
  assume_role_policy = data.aws_iam_policy_document.roleA_trust.json
}

data "aws_iam_policy_document" "roleA_permissions" {
  provider = aws.account_a

  statement {
    sid       = "AllowEverything"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid       = "DenyIAM"
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "roleA_permissions" {
  provider = aws.account_a
  name     = "roleA-admin-except-iam"
  role     = aws_iam_role.roleA.id
  policy   = data.aws_iam_policy_document.roleA_permissions.json
}

# --- roleB: can only assume roleC in Account B ---
data "aws_iam_policy_document" "roleB_trust" {
  provider = aws.account_a
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "roleB" {
  provider           = aws.account_a
  name               = "roleB"
  assume_role_policy = data.aws_iam_policy_document.roleB_trust.json
}

data "aws_iam_policy_document" "roleB_permissions" {
  provider = aws.account_a
  statement {
    sid       = "AssumeRoleCInAccountB"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.account_b_id}:role/roleC"]
  }
}

resource "aws_iam_role_policy" "roleB_permissions" {
  provider = aws.account_a
  name     = "roleB-assume-rolec"
  role     = aws_iam_role.roleB.id
  policy   = data.aws_iam_policy_document.roleB_permissions.json
}
