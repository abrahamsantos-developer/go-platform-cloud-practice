output "bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}

output "table_name" {
  value = aws_dynamodb_table.app_table.name
}
