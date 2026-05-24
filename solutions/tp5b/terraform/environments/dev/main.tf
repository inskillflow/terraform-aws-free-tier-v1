################################################################################
# TP 5 - Environnement DEV
#
# Reutilise les modules `../../modules/{s3_bucket,dynamodb_table,sqs_queue}`.
################################################################################

locals {
  common_tags = {
    Project     = "tp5"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

module "data_bucket" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${var.project_prefix}-tp5-${var.environment}-data-${random_id.suffix.hex}"
  tags        = merge(local.common_tags, { Purpose = "data" })
}

module "items_table" {
  source     = "../../modules/dynamodb_table"
  table_name = "${var.project_prefix}-tp5-${var.environment}-items"
  hash_key   = "pk"
  tags       = merge(local.common_tags, { Purpose = "items" })
}

module "events_queue" {
  source     = "../../modules/sqs_queue"
  queue_name = "${var.project_prefix}-tp5-${var.environment}-events"
  tags       = merge(local.common_tags, { Purpose = "events" })
}
