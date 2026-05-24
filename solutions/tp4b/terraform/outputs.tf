output "data_bucket_name" {
  value = module.data_bucket.bucket_id
}

output "data_bucket_arn" {
  value = module.data_bucket.bucket_arn
}

output "items_table_name" {
  value = module.items_table.table_name
}

output "items_table_arn" {
  value = module.items_table.table_arn
}

output "events_queue_name" {
  value = module.events_queue.queue_name
}

output "events_queue_url" {
  value = module.events_queue.queue_url
}

output "events_queue_arn" {
  value = module.events_queue.queue_arn
}

output "region" {
  value = var.region
}
