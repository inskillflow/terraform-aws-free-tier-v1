################################################################################
# TP 2 - Identique au TP 1 (S3 + DynamoDB), mais valide par une UI Streamlit.
################################################################################

locals {
  common_tags = {
    Project     = "tp2"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

# S3
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_prefix}-tp2-data-${random_id.suffix.hex}"
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

# DynamoDB
resource "aws_dynamodb_table" "items" {
  name         = "${var.project_prefix}-tp2-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = local.common_tags
}
