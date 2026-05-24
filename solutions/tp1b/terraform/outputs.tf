output "data_bucket_name" {
  description = "Nom du bucket S3 créé."
  value       = aws_s3_bucket.data.bucket
}

output "data_bucket_arn" {
  description = "ARN du bucket S3."
  value       = aws_s3_bucket.data.arn
}

output "items_table_name" {
  description = "Nom de la table DynamoDB."
  value       = aws_dynamodb_table.items.name
}

output "items_table_arn" {
  description = "ARN de la table DynamoDB."
  value       = aws_dynamodb_table.items.arn
}

output "region" {
  description = "Région utilisée."
  value       = var.region
}
