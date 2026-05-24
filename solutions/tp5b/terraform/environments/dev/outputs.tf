output "environment"        { value = var.environment }
output "data_bucket_name"   { value = module.data_bucket.bucket_id }
output "items_table_name"   { value = module.items_table.table_name }
output "events_queue_name"  { value = module.events_queue.queue_name }
output "events_queue_url"   { value = module.events_queue.queue_url }
