output "config" {
  value = {
    bucket         = aws_s3_bucket.state.id
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.default.arn
    dynamodb_table = aws_dynamodb_table.state_lock.name
  }
}
