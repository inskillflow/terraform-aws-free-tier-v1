################################################################################
# TP 4 - Refactor du TP 3 en modules Terraform locaux.
#
# Memes ressources (S3 + DynamoDB + SQS) que TP 3, mais delegues a 3 modules
# dans `modules/` que l'on peut reutiliser dans le TP 5.
################################################################################

locals {
  common_tags = {
    Project     = "tp4"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

# -----------------------------------------------------------------------------
# Bucket "data" via module
# -----------------------------------------------------------------------------
module "data_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "${var.project_prefix}-tp4-data-${random_id.suffix.hex}"
  tags        = merge(local.common_tags, { Purpose = "data" })
}

# -----------------------------------------------------------------------------
# Table DynamoDB "items" via module
# -----------------------------------------------------------------------------
module "items_table" {
  source     = "./modules/dynamodb_table"
  table_name = "${var.project_prefix}-tp4-items"
  hash_key   = "pk"
  tags       = merge(local.common_tags, { Purpose = "items" })
}

# -----------------------------------------------------------------------------
# Queue SQS "events" via module
# -----------------------------------------------------------------------------
module "events_queue" {
  source     = "./modules/sqs_queue"
  queue_name = "${var.project_prefix}-tp4-events"
  tags       = merge(local.common_tags, { Purpose = "events" })
}
