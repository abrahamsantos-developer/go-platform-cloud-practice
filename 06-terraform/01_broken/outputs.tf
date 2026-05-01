output "bucket_name" {
  value = aws_s3_bucket.app_state_demo.bucket
}

output "table_name" {
  value = aws_dynamodb_table.app_data.name
}
