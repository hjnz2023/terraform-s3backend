output "config" {
  value = {
    bucket         = aws_s3_bucket.state.id
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.terraform_state_access.arn
    dynamodb_table = aws_dynamodb_table.terrafrom_state_lock.name
  }
}
