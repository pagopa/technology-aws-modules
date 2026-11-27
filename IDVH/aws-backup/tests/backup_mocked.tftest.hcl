mock_provider "aws" {
  source = "tests/mocks"
  mock_data "aws_region" {
    defaults = { name = "eu-south-1" }
  }
}

mock_provider "aws" {
  alias  = "dr"
  source = "tests/mocks"
  mock_data "aws_region" {
    defaults = { name = "eu-central-1" }
  }
  mock_resource "aws_kms_key" {
    defaults = {
      arn    = "arn:aws:kms:eu-central-1:123456789012:key/00000000-0000-0000-0000-000000000002"
      key_id = "00000000-0000-0000-0000-000000000002"
    }
  }
}

variables {
  product_name                    = "aws-backup"
  env                             = "dev"
  aws_region                      = "eu-south-1"
  solution_prefix                 = "test-idvh-backup"
  selection_tags                  = { backup-workload = "test-workload" }
  coverage_expected_resource_tags = { backup-workload = "test-workload" }
  email_endpoints                 = ["backup@example.com"]
}

run "development_baseline" {
  state_key = "dev"
  command   = apply
  assert {
    condition     = output.vault_name == "test-idvh-backup" && output.dr_vault_arn == null && output.idvh_tier_config.retention_days == 7
    error_message = "Dev must create a primary vault with the 7-day catalog policy and no DR vault."
  }
  assert {
    condition = (
      output.effective_config.copy_retention_days == 7 &&
      output.effective_config.continuous_retention_days == 7 &&
      output.effective_config.vault_lock_min_retention_days == 1 &&
      output.effective_config.coverage_policy == {
        max_backup_age_seconds      = 172800
        freshness_tolerance_seconds = 14400
        initial_grace_seconds       = 259200
        reminder_interval_seconds   = 172800
        schedule                    = "rate(1 hour)"
      }
    )
    error_message = "Dev must apply shorter retention and less sensitive, hourly Coverage checks."
  }
  assert {
    condition     = output.coverage_lambda_function_arn != null && output.sns_topic_arn != null && length(module.alerting[0].coverage_health_alarm_arns) == 5
    error_message = "The wrapper must compose one scanner, its health alarms and the alert topic."
  }
  assert {
    condition     = module.backup.continuous_plan_id == null && module.backup.restore_testing_plan_arn == null
    error_message = "The standard tier must not implicitly enable PITR or restore testing."
  }
}

run "uat_baseline" {
  state_key = "uat"
  command   = apply
  variables { env = "uat" }
  assert {
    condition     = output.dr_vault_arn == null && output.idvh_tier_config.retention_days == 14
    error_message = "UAT must use its own catalog and the non-production policy."
  }
  assert {
    condition = (
      output.effective_config.copy_retention_days == 14 &&
      output.effective_config.continuous_retention_days == 14 &&
      output.effective_config.vault_lock_min_retention_days == 7 &&
      output.effective_config.coverage_policy == {
        max_backup_age_seconds      = 129600
        freshness_tolerance_seconds = 7200
        initial_grace_seconds       = 172800
        reminder_interval_seconds   = 86400
        schedule                    = "rate(30 minutes)"
      }
    )
    error_message = "UAT must apply 14-day retention and less sensitive, half-hourly Coverage checks."
  }
}

run "production_baseline" {
  state_key = "prod"
  command   = apply
  variables {
    env = "prod"
  }
  assert {
    condition     = output.dr_vault_arn != null && output.idvh_tier_config.retention_days == 35 && output.effective_config.copy_retention_days == 35 && output.effective_config.continuous_retention_days == 35 && output.effective_config.vault_lock_min_retention_days == 30
    error_message = "Prod must create DR and use the production retention and lock policy."
  }
  assert {
    condition = output.effective_config.coverage_policy == {
      max_backup_age_seconds      = 86400
      freshness_tolerance_seconds = 3600
      initial_grace_seconds       = 86400
      reminder_interval_seconds   = 86400
      schedule                    = "rate(15 minutes)"
    }
    error_message = "Relaxing non-production must not weaken the production Coverage policy."
  }
}

run "production_dr_override" {
  state_key = "custom-dr"
  command   = apply
  variables {
    env       = "prod"
    dr_region = "eu-west-1"
  }
  override_data {
    target = module.backup.data.aws_region.dr[0]
    values = { name = "eu-west-1" }
  }
  assert {
    condition     = output.dr_vault_arn != null && output.effective_config.dr_region == "eu-west-1"
    error_message = "An explicit DR override must replace the catalog region and use the matching caller provider."
  }
}

run "distinct_selection_and_inventory_tags" {
  state_key = "distinct-tags"
  command   = apply
  variables {
    selection_tags                  = { backup-workload = "test-workload", backup-group = "shared" }
    coverage_expected_resource_tags = { expected-workload = "test-workload" }
    tags                            = { Environment = "caller-env", Product = "caller-product", owner = "team" }
  }
  assert {
    condition     = output.backup_plan_arn != null && output.coverage_lambda_function_arn != null
    error_message = "The wrapper must accept independent backup and coverage selectors without conflating them."
  }
}

run "invalid_catalog_rejected" {
  state_key = "invalid"
  command   = plan
  override_module {
    target = module.idvh_loader
    outputs = {
      idvh_resource_configuration = {
        dr_region                      = null
        retention_days                 = 14
        copy_retention_days            = 14
        backup_schedule                = "cron(0 1 * * ? *)"
        backup_window_minutes          = 480
        vault_lock_mode                = "GOVERNANCE"
        vault_lock_min_retention_days  = 7
        vault_lock_max_retention_days  = 3650
        vault_lock_changeable_for_days = 3
        default_plan_additional_rules  = []
        enable_continuous_backup       = false
        continuous_retention_days      = 35
        enable_restore_testing         = false
        restore_testing_resource_types = ["DynamoDB", "EBS", "RDS", "S3", "EFS"]
        restore_testing_schedule       = "cron(0 3 ? * SAT *)"
        restore_testing_start_window   = 480
        restore_testing_max_duration   = 24
        enable_alerting                = true
        enable_backup_failure_alerts   = true
        enable_kms_deletion_alert      = true
        enable_backup_coverage         = true
        coverage_resource_types        = ["RDS"]
        coverage_policy = {
          max_backup_age_seconds      = 86400
          freshness_tolerance_seconds = 3600
          initial_grace_seconds       = 86400
          reminder_interval_seconds   = 86400
          schedule                    = "rate(15 minutes)"
        }
      }
    }
  }
  expect_failures = [check.backup_catalog, terraform_data.catalog]
}

run "catalog_override_integration" {
  state_key = "custom-policy"
  command   = apply
  override_module {
    target = module.idvh_loader
    outputs = {
      idvh_resource_configuration = {
        dr_region                      = null
        retention_days                 = 21
        copy_retention_days            = 21
        backup_schedule                = "cron(0 5 * * ? *)"
        backup_window_minutes          = 120
        vault_lock_mode                = "GOVERNANCE"
        vault_lock_min_retention_days  = 7
        vault_lock_max_retention_days  = 3650
        vault_lock_changeable_for_days = 3
        default_plan_additional_rules  = []
        enable_continuous_backup       = false
        continuous_retention_days      = 35
        enable_restore_testing         = false
        restore_testing_resource_types = ["DynamoDB", "EBS", "RDS", "S3", "EFS"]
        restore_testing_schedule       = "cron(0 3 ? * SAT *)"
        restore_testing_start_window   = 480
        restore_testing_max_duration   = 24
        enable_alerting                = true
        enable_backup_failure_alerts   = true
        enable_kms_deletion_alert      = true
        enable_backup_coverage         = true
        coverage_resource_types        = ["DynamoDB", "S3"]
        coverage_policy = {
          max_backup_age_seconds      = 86400
          freshness_tolerance_seconds = 3600
          initial_grace_seconds       = 86400
          reminder_interval_seconds   = 86400
          schedule                    = "rate(15 minutes)"
        }
      }
    }
  }
  assert {
    condition     = output.backup_plan_arn != null && output.idvh_tier_config.retention_days == 21 && output.idvh_tier_config.backup_schedule == "cron(0 5 * * ? *)"
    error_message = "The original module must accept the overridden catalog policy and create a backup plan."
  }
}

run "explicit_false_disables_alerting" {
  state_key = "disabled-alerting"
  command   = apply
  variables {
    enable_alerting                 = false
    email_endpoints                 = []
    coverage_expected_resource_tags = {}
  }
  assert {
    condition     = output.sns_topic_arn == null && output.coverage_lambda_function_arn == null && output.vault_arn != null
    error_message = "Explicit false must override the catalog and disable alerts and coverage without disabling backup."
  }
}

run "explicit_false_disables_coverage" {
  state_key = "disabled-coverage"
  command   = apply
  variables {
    enable_backup_coverage          = false
    enable_backup_failure_alerts    = false
    enable_kms_deletion_alert       = false
    coverage_expected_resource_tags = {}
    coverage_resource_types         = []
  }
  assert {
    condition     = output.sns_topic_arn != null && output.coverage_lambda_function_arn == null
    error_message = "Explicit false must retain alerting while disabling coverage."
  }
  assert {
    condition     = module.alerting[0].eventbridge_rule_arn == null && module.alerting[0].kms_deletion_rule_arn == null
    error_message = "Explicit false must also override the catalog event-rule toggles."
  }
}

run "continuous_backup_override" {
  state_key = "continuous"
  command   = apply
  variables {
    enable_continuous_backup         = true
    continuous_backup_selection_tags = { backup-pitr = "test-s3" }
    continuous_retention_days        = 10
  }
  assert {
    condition     = module.backup.continuous_plan_id != null
    error_message = "An explicit continuous-backup override must create the dedicated PITR plan."
  }
}

run "restore_testing_override" {
  state_key = "restore-testing"
  command   = apply
  variables {
    enable_restore_testing         = true
    restore_testing_resource_types = ["S3"]
    restore_testing_schedule       = "cron(0 4 ? * SAT *)"
    restore_testing_start_window   = 120
    restore_testing_max_duration   = 6
  }
  assert {
    condition     = module.backup.restore_testing_plan_arn != null
    error_message = "An explicit restore-testing override must create the restore plan."
  }
}

run "policy_overrides_and_additional_rules" {
  state_key = "policy-overrides"
  command   = apply
  variables {
    env                            = "prod"
    retention_days                 = 21
    copy_retention_days            = 22
    backup_schedule                = "cron(0 5 * * ? *)"
    backup_window_minutes          = 120
    vault_lock_mode                = "COMPLIANCE"
    vault_lock_min_retention_days  = 5
    vault_lock_max_retention_days  = 400
    vault_lock_changeable_for_days = 4
    default_plan_additional_rules = [{
      rule_name    = "weekly"
      schedule     = "cron(0 2 ? * SUN *)"
      delete_after = 90
    }]
    coverage_resource_types = ["S3"]
    coverage_policy = {
      max_backup_age_seconds      = 172800
      freshness_tolerance_seconds = 7200
      initial_grace_seconds       = 43200
      reminder_interval_seconds   = 86400
      schedule                    = "rate(30 minutes)"
    }
  }
  assert {
    condition     = output.effective_config.retention_days == 21 && length(output.effective_config.default_plan_additional_rules) == 1 && output.backup_plan_arn != null && output.coverage_lambda_function_arn != null
    error_message = "Consumer policy overrides and additional rules must replace catalog defaults and remain deployable."
  }
}

run "empty_list_and_false_replace_enabled_catalog" {
  state_key = "empty-overrides"
  command   = apply
  override_module {
    target = module.idvh_loader
    outputs = {
      idvh_resource_configuration = {
        dr_region                      = null
        retention_days                 = 14
        copy_retention_days            = 14
        backup_schedule                = "cron(0 1 * * ? *)"
        backup_window_minutes          = 480
        vault_lock_mode                = "GOVERNANCE"
        vault_lock_min_retention_days  = 7
        vault_lock_max_retention_days  = 3650
        vault_lock_changeable_for_days = 3
        default_plan_additional_rules = [{
          rule_name    = "catalog-weekly"
          schedule     = "cron(0 2 ? * SUN *)"
          delete_after = 21
        }]
        enable_continuous_backup       = true
        enable_restore_testing         = true
        continuous_retention_days      = 35
        restore_testing_resource_types = ["DynamoDB", "EBS", "RDS", "S3", "EFS"]
        restore_testing_schedule       = "cron(0 3 ? * SAT *)"
        restore_testing_start_window   = 480
        restore_testing_max_duration   = 24
        enable_alerting                = true
        enable_backup_failure_alerts   = true
        enable_kms_deletion_alert      = true
        enable_backup_coverage         = true
        coverage_resource_types        = ["DynamoDB", "S3"]
        coverage_policy = {
          max_backup_age_seconds      = 86400
          freshness_tolerance_seconds = 3600
          initial_grace_seconds       = 86400
          reminder_interval_seconds   = 86400
          schedule                    = "rate(15 minutes)"
        }
      }
    }
  }
  variables {
    default_plan_additional_rules  = []
    enable_continuous_backup       = false
    enable_restore_testing         = false
    restore_testing_resource_types = []
  }
  assert {
    condition     = length(output.effective_config.default_plan_additional_rules) == 0 && output.continuous_plan_id == null && output.restore_testing_plan_arn == null
    error_message = "Empty lists and false must override non-empty and enabled catalog defaults."
  }
}

run "primary_dr_and_workload_keys" {
  state_key = "all-keys"
  command   = apply
  variables {
    env                    = "prod"
    additional_kms_key_ids = ["workload-key", "workload-key"]
  }

  assert {
    condition     = length(local.monitored_kms_key_ids) == 3 && contains(local.monitored_kms_key_ids, output.kms_key_id) && contains(local.monitored_kms_key_ids, output.dr_kms_key_id) && contains(local.monitored_kms_key_ids, "workload-key")
    error_message = "Alerting must retain primary, DR and external workload keys while deduplicating the list."
  }
}

run "catalog_additional_rules_without_override" {
  state_key = "catalog-rules"
  command   = apply
  override_module {
    target = module.idvh_loader
    outputs = {
      idvh_resource_configuration = {
        dr_region                      = null
        retention_days                 = 14
        copy_retention_days            = 14
        backup_schedule                = "cron(0 1 * * ? *)"
        backup_window_minutes          = 480
        vault_lock_mode                = "GOVERNANCE"
        vault_lock_min_retention_days  = 7
        vault_lock_max_retention_days  = 3650
        vault_lock_changeable_for_days = 3
        default_plan_additional_rules = [{
          rule_name    = "catalog-weekly"
          schedule     = "cron(0 2 ? * SUN *)"
          delete_after = 21
        }]
        enable_continuous_backup       = false
        continuous_retention_days      = 35
        enable_restore_testing         = false
        restore_testing_resource_types = ["DynamoDB", "EBS", "RDS", "S3", "EFS"]
        restore_testing_schedule       = "cron(0 3 ? * SAT *)"
        restore_testing_start_window   = 480
        restore_testing_max_duration   = 24
        enable_alerting                = true
        enable_backup_failure_alerts   = true
        enable_kms_deletion_alert      = true
        enable_backup_coverage         = true
        coverage_resource_types        = ["DynamoDB", "S3"]
        coverage_policy = {
          max_backup_age_seconds      = 86400
          freshness_tolerance_seconds = 3600
          initial_grace_seconds       = 86400
          reminder_interval_seconds   = 86400
          schedule                    = "rate(15 minutes)"
        }
      }
    }
  }
  assert {
    condition     = output.backup_plan_arn != null && length(output.effective_config.default_plan_additional_rules) == 1
    error_message = "YAML rules with omitted optional fields must reach the original module and its typed defaults."
  }
}
