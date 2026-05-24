output "data_bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "data_bucket_arn" {
  value = aws_s3_bucket.data.arn
}

output "items_table_name" {
  value = aws_dynamodb_table.items.name
}

output "items_table_arn" {
  value = aws_dynamodb_table.items.arn
}

output "region" {
  value = var.region
}
