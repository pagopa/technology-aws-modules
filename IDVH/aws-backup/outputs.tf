output "idvh_tier_config" {
  description = "Selected catalog policy."
  value       = local.idvh_config
}

output "effective_config" {
  description = "Catalog policy after explicit consumer overrides."
  value       = local.effective_config
}

output "vault_name" {
  description = "Primary backup vault name."
  value       = module.backup.vault_name
}

output "vault_arn" {
  description = "Primary backup vault ARN."
  value       = module.backup.vault_arn
}

output "dr_vault_arn" {
  description = "DR vault ARN, or null outside production."
  value       = module.backup.dr_vault_arn
}

output "backup_plan_arn" {
  description = "Scheduled snapshot backup plan ARN."
  value       = module.backup.backup_plan_arn
}

output "kms_key_id" {
  description = "Primary vault KMS key ID."
  value       = module.backup.kms_key_id
}

output "dr_kms_key_id" {
  description = "DR vault KMS key ID, or null outside production."
  value       = module.backup.dr_kms_key_id
}

output "continuous_plan_id" {
  description = "Continuous backup plan ID, or null when disabled."
  value       = module.backup.continuous_plan_id
}

output "restore_testing_plan_arn" {
  description = "Restore testing plan ARN, or null when disabled."
  value       = module.backup.restore_testing_plan_arn
}

output "sns_topic_arn" {
  description = "Encrypted backup notification topic ARN."
  value       = local.effective_config.enable_alerting ? module.alerting[0].sns_topic_arn : null
}

output "coverage_lambda_function_arn" {
  description = "Coverage scanner ARN, or null when the catalog disables it."
  value       = local.effective_config.enable_alerting ? module.alerting[0].coverage_lambda_function_arn : null
}
