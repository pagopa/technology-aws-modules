module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "aws-backup"
}

locals {
  core_environment = var.env == "prod" ? "prod" : "nonprod"
  effective_config = {
    dr_region                      = var.dr_region != null ? var.dr_region : local.idvh_config.dr_region
    backup_schedule                = var.backup_schedule != null ? var.backup_schedule : local.idvh_config.backup_schedule
    backup_window_minutes          = var.backup_window_minutes != null ? var.backup_window_minutes : local.idvh_config.backup_window_minutes
    retention_days                 = var.retention_days != null ? var.retention_days : local.idvh_config.retention_days
    copy_retention_days            = var.copy_retention_days != null ? var.copy_retention_days : local.idvh_config.copy_retention_days
    vault_lock_mode                = var.vault_lock_mode != null ? var.vault_lock_mode : local.idvh_config.vault_lock_mode
    vault_lock_min_retention_days  = var.vault_lock_min_retention_days != null ? var.vault_lock_min_retention_days : local.idvh_config.vault_lock_min_retention_days
    vault_lock_max_retention_days  = var.vault_lock_max_retention_days != null ? var.vault_lock_max_retention_days : local.idvh_config.vault_lock_max_retention_days
    vault_lock_changeable_for_days = var.vault_lock_changeable_for_days != null ? var.vault_lock_changeable_for_days : local.idvh_config.vault_lock_changeable_for_days
    # Keep YAML rule objects separate from typed overrides until the source module applies its optional-field defaults.
    default_plan_additional_rules = concat(
      var.default_plan_additional_rules != null ? var.default_plan_additional_rules : [],
      var.default_plan_additional_rules == null ? local.idvh_config.default_plan_additional_rules : []
    )
    enable_continuous_backup       = var.enable_continuous_backup != null ? var.enable_continuous_backup : local.idvh_config.enable_continuous_backup
    continuous_retention_days      = var.continuous_retention_days != null ? var.continuous_retention_days : local.idvh_config.continuous_retention_days
    enable_restore_testing         = var.enable_restore_testing != null ? var.enable_restore_testing : local.idvh_config.enable_restore_testing
    restore_testing_resource_types = var.restore_testing_resource_types != null ? var.restore_testing_resource_types : local.idvh_config.restore_testing_resource_types
    restore_testing_schedule       = var.restore_testing_schedule != null ? var.restore_testing_schedule : local.idvh_config.restore_testing_schedule
    restore_testing_start_window   = var.restore_testing_start_window != null ? var.restore_testing_start_window : local.idvh_config.restore_testing_start_window
    restore_testing_max_duration   = var.restore_testing_max_duration != null ? var.restore_testing_max_duration : local.idvh_config.restore_testing_max_duration
    enable_alerting                = var.enable_alerting != null ? var.enable_alerting : local.idvh_config.enable_alerting
    enable_backup_failure_alerts   = var.enable_backup_failure_alerts != null ? var.enable_backup_failure_alerts : local.idvh_config.enable_backup_failure_alerts
    enable_kms_deletion_alert      = var.enable_kms_deletion_alert != null ? var.enable_kms_deletion_alert : local.idvh_config.enable_kms_deletion_alert
    enable_backup_coverage         = var.enable_backup_coverage != null ? var.enable_backup_coverage : local.idvh_config.enable_backup_coverage
    coverage_resource_types        = var.coverage_resource_types != null ? var.coverage_resource_types : local.idvh_config.coverage_resource_types
    coverage_policy                = var.coverage_policy != null ? var.coverage_policy : local.idvh_config.coverage_policy
  }

  monitored_kms_key_ids = distinct(compact(concat(
    [module.backup.kms_key_id, module.backup.dr_kms_key_id],
    var.additional_kms_key_ids
  )))
}

module "backup" {
  source = "git::https://github.com/pagopa/eng-cloud-strategy-hub.git//terraform/aws/modules/terraform-aws-backup?ref=d30c3641dcb68628d9a67f1807ec4c06f3772064"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  environment     = local.core_environment
  aws_region      = var.aws_region
  dr_region       = local.effective_config.dr_region
  solution_prefix = var.solution_prefix
  selection_tags  = var.selection_tags

  retention_days                 = local.effective_config.retention_days
  copy_retention_days            = local.effective_config.copy_retention_days
  backup_schedule                = local.effective_config.backup_schedule
  backup_window_minutes          = local.effective_config.backup_window_minutes
  vault_lock_mode                = local.effective_config.vault_lock_mode
  vault_lock_min_retention_days  = local.effective_config.vault_lock_min_retention_days
  vault_lock_max_retention_days  = local.effective_config.vault_lock_max_retention_days
  vault_lock_changeable_for_days = local.effective_config.vault_lock_changeable_for_days
  default_plan_additional_rules  = local.effective_config.default_plan_additional_rules

  enable_continuous_backup         = local.effective_config.enable_continuous_backup
  continuous_backup_selection_tags = var.continuous_backup_selection_tags
  continuous_retention_days        = local.effective_config.continuous_retention_days

  enable_restore_testing         = local.effective_config.enable_restore_testing
  restore_testing_resource_types = local.effective_config.restore_testing_resource_types
  restore_testing_schedule       = local.effective_config.restore_testing_schedule
  restore_testing_start_window   = local.effective_config.restore_testing_start_window
  restore_testing_max_duration   = local.effective_config.restore_testing_max_duration

  tags       = var.tags
  depends_on = [terraform_data.catalog]
}

module "alerting" {
  count  = local.effective_config.enable_alerting ? 1 : 0
  source = "git::https://github.com/pagopa/eng-cloud-strategy-hub.git//terraform/aws/modules/terraform-aws-backup-alerting?ref=d30c3641dcb68628d9a67f1807ec4c06f3772064"

  solution_prefix = var.solution_prefix
  kms_key_ids     = local.monitored_kms_key_ids
  email_endpoints = var.email_endpoints

  enable_backup_failure_alerts = local.effective_config.enable_backup_failure_alerts
  enable_kms_deletion_alert    = local.effective_config.enable_kms_deletion_alert
  enable_backup_coverage       = local.effective_config.enable_backup_coverage

  coverage_expected_resource_tags = var.coverage_expected_resource_tags
  coverage_resource_types         = local.effective_config.coverage_resource_types
  coverage_policy                 = local.effective_config.coverage_policy

  tags       = var.tags
  depends_on = [terraform_data.catalog]
}
