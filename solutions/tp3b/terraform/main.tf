################################################################################
# TP 3 - Ajouter SQS au projet TP 2 (S3 + DynamoDB + SQS)
################################################################################

locals {
  common_tags = {
    Project     = "tp3"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_prefix}-tp3-data-${random_id.suffix.hex}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# DynamoDB
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "items" {
  name         = "${var.project_prefix}-tp3-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# SQS (Standard queue)
# -----------------------------------------------------------------------------
resource "aws_sqs_queue" "events" {
  name                       = "${var.project_prefix}-tp3-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 jour
  receive_wait_time_seconds  = 20    # long polling
  sqs_managed_sse_enabled    = true

  tags = local.common_tags
}
