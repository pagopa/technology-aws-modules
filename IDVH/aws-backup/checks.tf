locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "dr_region",
    "retention_days", "copy_retention_days", "backup_schedule",
    "backup_window_minutes", "vault_lock_mode", "vault_lock_min_retention_days",
    "enable_backup_failure_alerts", "enable_kms_deletion_alert",
    "enable_backup_coverage", "coverage_resource_types", "coverage_policy",
    "vault_lock_max_retention_days", "vault_lock_changeable_for_days",
    "default_plan_additional_rules", "enable_continuous_backup",
    "continuous_retention_days", "enable_restore_testing",
    "restore_testing_resource_types", "restore_testing_schedule",
    "restore_testing_start_window", "restore_testing_max_duration", "enable_alerting",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  # Invalid or incomplete catalogs fail the check and the blocking precondition.
  catalog_valid = try(
    length(local.missing_tier_keys) == 0 &&
    (local.idvh_config.dr_region == null ? true : local.idvh_config.dr_region == tostring(local.idvh_config.dr_region) && length(trimspace(local.idvh_config.dr_region)) > 0) &&
    alltrue([
      for days in [local.idvh_config.retention_days, local.idvh_config.copy_retention_days, local.idvh_config.vault_lock_min_retention_days, local.idvh_config.vault_lock_max_retention_days, local.idvh_config.continuous_retention_days] :
      days == tonumber(days) && days >= 1 && floor(days) == days
    ]) &&
    local.idvh_config.retention_days >= local.idvh_config.vault_lock_min_retention_days &&
    local.idvh_config.copy_retention_days >= local.idvh_config.vault_lock_min_retention_days &&
    local.idvh_config.retention_days <= local.idvh_config.vault_lock_max_retention_days &&
    local.idvh_config.copy_retention_days <= local.idvh_config.vault_lock_max_retention_days &&
    contains(["GOVERNANCE", "COMPLIANCE"], local.idvh_config.vault_lock_mode) &&
    local.idvh_config.vault_lock_changeable_for_days == tonumber(local.idvh_config.vault_lock_changeable_for_days) &&
    local.idvh_config.vault_lock_changeable_for_days >= 3 &&
    local.idvh_config.continuous_retention_days <= 35 &&
    startswith(local.idvh_config.backup_schedule, "cron(") &&
    local.idvh_config.backup_window_minutes == tonumber(local.idvh_config.backup_window_minutes) &&
    local.idvh_config.backup_window_minutes >= 60 &&
    floor(local.idvh_config.backup_window_minutes) == local.idvh_config.backup_window_minutes &&
    alltrue([
      for enabled in [local.idvh_config.enable_backup_failure_alerts, local.idvh_config.enable_kms_deletion_alert, local.idvh_config.enable_backup_coverage, local.idvh_config.enable_alerting, local.idvh_config.enable_continuous_backup, local.idvh_config.enable_restore_testing] :
      enabled == tobool(enabled)
    ]) &&
    alltrue([
      for rule in local.idvh_config.default_plan_additional_rules :
      rule.rule_name == tostring(rule.rule_name) &&
      startswith(rule.schedule, "cron(") &&
      rule.delete_after == tonumber(rule.delete_after) && rule.delete_after >= 1 && floor(rule.delete_after) == rule.delete_after
    ]) &&
    alltrue([
      for resource_type in local.idvh_config.restore_testing_resource_types :
      contains(["Aurora", "DocumentDB", "DynamoDB", "EBS", "EC2", "EFS", "FSx", "Neptune", "RDS", "Redshift", "S3"], resource_type)
    ]) &&
    startswith(local.idvh_config.restore_testing_schedule, "cron(") &&
    local.idvh_config.restore_testing_start_window == tonumber(local.idvh_config.restore_testing_start_window) &&
    local.idvh_config.restore_testing_start_window >= 60 && local.idvh_config.restore_testing_start_window <= 10080 &&
    local.idvh_config.restore_testing_start_window % 60 == 0 &&
    local.idvh_config.restore_testing_max_duration == tonumber(local.idvh_config.restore_testing_max_duration) &&
    local.idvh_config.restore_testing_max_duration >= 1 && local.idvh_config.restore_testing_max_duration <= 168 &&
    floor(local.idvh_config.restore_testing_max_duration) == local.idvh_config.restore_testing_max_duration &&
    length(local.idvh_config.coverage_resource_types) > 0 &&
    length(setsubtract(toset(local.idvh_config.coverage_resource_types), toset(["DynamoDB", "S3"]))) == 0 &&
    alltrue([
      for seconds in [
        local.idvh_config.coverage_policy.max_backup_age_seconds,
        local.idvh_config.coverage_policy.freshness_tolerance_seconds,
        local.idvh_config.coverage_policy.initial_grace_seconds,
        local.idvh_config.coverage_policy.reminder_interval_seconds,
      ] : seconds == tonumber(seconds) && seconds >= 0 && floor(seconds) == seconds
    ]) &&
    local.idvh_config.coverage_policy.max_backup_age_seconds > 0 &&
    local.idvh_config.coverage_policy.freshness_tolerance_seconds < local.idvh_config.coverage_policy.max_backup_age_seconds &&
    can(regex("^rate\\([1-9][0-9]* (minute|minutes|hour|hours)\\)$", local.idvh_config.coverage_policy.schedule)),
    false
  )
}

check "backup_catalog" {
  assert {
    condition     = local.catalog_valid
    error_message = "Invalid aws-backup tier: use complete, typed backup, Vault Lock, PITR, restore and DynamoDB/S3 coverage policies."
  }
}

resource "terraform_data" "catalog" {
  lifecycle {
    precondition {
      condition     = local.catalog_valid
      error_message = "Invalid aws-backup catalog. Fix the selected YAML tier before planning or deploying backup infrastructure."
    }
  }
}
