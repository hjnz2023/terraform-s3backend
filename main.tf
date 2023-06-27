data "aws_region" "current" {}

resource "random_string" "rand" {
  length  = var.namespace_random_length
  special = false
  upper   = false
}

locals {
  namespace = substr(join("-", [var.namespace, random_string.rand.result]), 0, var.namespace_random_length)
}

resource "aws_resourcegroups_group" "default" {
  name = "${local.namespace}-terraform-state-group"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "ResourceGroup",
          Values = ["${local.namespace}"]
        }
      ]
    })
  }
}

resource "aws_kms_key" "default" {
  tags = {
    ResourceGroup = local.namespace
  }
}

resource "aws_s3_bucket" "state" {
  bucket        = "${local.namespace}-terrafrom-state"
  force_destroy = var.force_destroy_state

  tags = {
    ResourceGroup = local.namespace
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.default.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terrafrom_state_lock" {
  name         = "${local.namespace}-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    ResourceGroup = local.namespace
  }
}
