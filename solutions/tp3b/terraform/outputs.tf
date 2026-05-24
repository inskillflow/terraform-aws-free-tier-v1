output "data_bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "items_table_name" {
  value = aws_dynamodb_table.items.name
}

output "events_queue_name" {
  value = aws_sqs_queue.events.name
}

output "events_queue_url" {
  value = aws_sqs_queue.events.id
}

output "events_queue_arn" {
  value = aws_sqs_queue.events.arn
}

output "region" {
  value = var.region
}
