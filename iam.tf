data "aws_caller_identity" "current" {}

locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

data "aws_iam_policy_document" "terraform_state_access_pricipal_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.principal_arns
    }
  }
}

resource "aws_iam_role" "terraform_state_access" {
  name               = "${local.namespace}-for-terraform-state-access"
  assume_role_policy = data.aws_iam_policy_document.terraform_state_access_pricipal_assume_role.json

  tags = {
    ResourceGroup = local.namespace
  }
}

data "aws_iam_policy_document" "terraform_state_access_full_access" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.state.arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.state.arn}/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [
      aws_dynamodb_table.terrafrom_state_lock.arn
    ]
  }
}

resource "aws_iam_policy" "terraform_state_full_access" {
  name   = "${local.namespace}-terraform-state-full-access-role-policy"
  policy = data.aws_iam_policy_document.terraform_state_access_full_access.json
}

resource "aws_iam_role_policy_attachment" "terraform_state_access_role_full_access" {
  role       = aws_iam_role.terraform_state_access.name
  policy_arn = aws_iam_policy.terraform_state_full_access.arn
}
