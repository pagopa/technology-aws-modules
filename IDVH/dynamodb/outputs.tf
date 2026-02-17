output "table_name" {
  value = module.dynamodb_table.dynamodb_table_id
}

output "table_arn" {
  value = module.dynamodb_table.dynamodb_table_arn
}

output "table_stream_arn" {
  value = module.dynamodb_table.dynamodb_table_stream_arn
}

output "table_stream_label" {
  value = module.dynamodb_table.dynamodb_table_stream_label
}

output "table_global_secondary_index_arns" {
  value = local.table_global_secondary_index_arns
}

output "kms_key_arn" {
  value = local.effective_server_side_encryption_kms_key_arn
}
