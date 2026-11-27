variable "product_name" {
  description = "Catalog name, independent of the workload name."
  type        = string
  nullable    = false
}

variable "env" {
  description = "Catalog environment: dev, uat or prod."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["dev", "uat", "prod"], var.env)
    error_message = "env must be dev, uat or prod."
  }
}

variable "idvh_resource_tier" {
  description = "Policy tier in the selected catalog."
  type        = string
  default     = "standard"
  nullable    = false
}

variable "solution_prefix" {
  description = "Unique resource prefix forwarded unchanged. Source modules enforce their generated-name limits."
  type        = string
  nullable    = false
}

variable "aws_region" {
  description = "Primary region matching the caller's aws provider."
  type        = string
  nullable    = false
}

variable "dr_region" {
  description = "Override the catalog DR region. Must match aws.dr and differ from aws_region in prod."
  type        = string
  default     = null
}

variable "selection_tags" {
  description = "Snapshot selection tags forwarded unchanged to Backup, where multiple tags match with OR semantics."
  type        = map(string)
  nullable    = false
}

variable "continuous_backup_selection_tags" {
  description = "Dedicated tags for supported continuous-backup resources. Required when PITR is enabled."
  type        = map(string)
  default     = null
}

variable "coverage_expected_resource_tags" {
  description = "Independent coverage inventory tags, matched with AND semantics. Required when coverage is enabled."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "additional_kms_key_ids" {
  description = "Workload key IDs or ARNs to monitor in addition to the backup primary and DR keys."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "email_endpoints" {
  description = "Backup notification recipients; each must confirm its SNS subscription."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "tags" {
  description = "Infrastructure tags forwarded unchanged. Scanner infrastructure must not match the expected workload inventory."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "backup_schedule" {
  description = "Override the catalog snapshot cron schedule."
  type        = string
  default     = null
}

variable "backup_window_minutes" {
  description = "Override the catalog snapshot start window in whole minutes."
  type        = number
  default     = null
}

variable "retention_days" {
  description = "Override catalog snapshot retention in whole days."
  type        = number
  default     = null
}

variable "copy_retention_days" {
  description = "Override catalog DR copy retention in whole days."
  type        = number
  default     = null
}

variable "vault_lock_mode" {
  description = "Override catalog Vault Lock mode. COMPLIANCE is explicit opt-in and becomes immutable."
  type        = string
  default     = null
}

variable "vault_lock_min_retention_days" {
  description = "Override the catalog minimum Vault Lock retention for both vaults."
  type        = number
  default     = null
}

variable "vault_lock_max_retention_days" {
  description = "Override the catalog maximum Vault Lock retention."
  type        = number
  default     = null
}

variable "vault_lock_changeable_for_days" {
  description = "Override the catalog COMPLIANCE cooling-off period."
  type        = number
  default     = null
}

variable "default_plan_additional_rules" {
  description = "Replace the catalog additional rules. An empty list explicitly disables catalog additional rules."
  type = list(object({
    rule_name               = string
    schedule                = string
    start_window            = optional(number)
    completion_window       = optional(number)
    cold_storage_after      = optional(number, 0)
    delete_after            = number
    recovery_point_tags     = optional(map(string), {})
    copy_to_dr              = optional(bool)
    copy_cold_storage_after = optional(number)
    copy_delete_after       = optional(number)
  }))
  default = null
}

variable "enable_continuous_backup" {
  description = "Override catalog continuous-backup activation. False is an explicit override."
  type        = bool
  default     = null
}

variable "continuous_retention_days" {
  description = "Override the catalog PITR retention, independently of snapshot retention."
  type        = number
  default     = null
}

variable "enable_restore_testing" {
  description = "Override catalog restore-testing activation. False is an explicit override."
  type        = bool
  default     = null
}

variable "restore_testing_resource_types" {
  description = "Replace catalog restore-testing resource types."
  type        = list(string)
  default     = null
}

variable "restore_testing_schedule" {
  description = "Override the catalog restore-testing cron schedule."
  type        = string
  default     = null
}

variable "restore_testing_start_window" {
  description = "Override the catalog restore-testing start window in minutes."
  type        = number
  default     = null
}

variable "restore_testing_max_duration" {
  description = "Override the catalog restore validation duration in hours."
  type        = number
  default     = null
}

variable "enable_alerting" {
  description = "Override catalog alerting activation. False disables Alerting and its Coverage scanner."
  type        = bool
  default     = null
}

variable "enable_backup_failure_alerts" {
  description = "Override catalog backup failure event alerts."
  type        = bool
  default     = null
}

variable "enable_kms_deletion_alert" {
  description = "Override catalog key deletion event alerts."
  type        = bool
  default     = null
}

variable "enable_backup_coverage" {
  description = "Override catalog coverage activation. False retains event-only alerting."
  type        = bool
  default     = null
}

variable "coverage_resource_types" {
  description = "Replace catalog coverage inventory types: DynamoDB and/or S3."
  type        = set(string)
  default     = null
}

variable "coverage_policy" {
  description = "Replace the catalog coverage policy; the whole object is overridden, not merged."
  type = object({
    max_backup_age_seconds      = number
    freshness_tolerance_seconds = number
    initial_grace_seconds       = number
    reminder_interval_seconds   = number
    schedule                    = string
  })
  default = null
}
