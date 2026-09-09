output "table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb_table.dynamodb_table_id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb_table.dynamodb_table_arn
}

output "idvh_tier_config" {
  description = "IDVH tier configuration for DynamoDB"
  value       = local.idvh_config
}

output "kms_key_arn" {
  description = "KMS key ARN for table encryption"
  value       = local.effective_server_side_encryption_kms_key_arn
}

output "kms_key_id" {
  description = "KMS key ID if created by this module"
  value       = var.create_kms_key ? module.kms_table_key[0].key_id : null
}
