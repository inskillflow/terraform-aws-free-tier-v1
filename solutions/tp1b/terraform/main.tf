################################################################################
# TP 1 - Premier projet Terraform sur AWS reel
#
# Cree :
#   - un bucket S3 (versioning + public access block + SSE-S3)
#   - une table DynamoDB en PAY_PER_REQUEST (Free Tier)
#
# Toutes les ressources sont taguees pour faciliter le suivi de cout.
################################################################################

locals {
  common_tags = {
    Project     = "tp1"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# Suffixe aleatoire pour eviter les collisions S3 (noms globaux).
resource "random_id" "suffix" {
  byte_length = 3
}

# -----------------------------------------------------------------------------
# Bucket S3
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_prefix}-tp1-data-${random_id.suffix.hex}"
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
# Table DynamoDB (Free Tier, On-Demand)
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "items" {
  name         = "${var.project_prefix}-tp1-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  tags = local.common_tags
}
