output "bucket_id" {
  description = "ID (= nom) du bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN du bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Domain name du bucket."
  value       = aws_s3_bucket.this.bucket_domain_name
}
