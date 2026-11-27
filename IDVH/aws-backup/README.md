# AWS Backup environment defaults

Thin IDVH wrapper that applies catalog defaults to the original AWS Backup and
Alerting modules in `pagopa/eng-cloud-strategy-hub`. Both Git sources are pinned
to the same immutable commit. Alerting composes Coverage in the source library;
this repository contains no copies of the implementation modules.

## Catalog

Use `product_name = "aws-backup"` and the `standard` tier. This selects a catalog,
not a workload identity. Catalog files are under
`IDVH/00_product_configs/aws-backup/{dev,uat,prod}/aws-backup.yml`.
The catalog is independent of other products. The former catalog name
`platform` is no longer available; consumers must update `product_name`.

| Environment | Snapshot/copy retention | GOVERNANCE minimum | DR |
| --- | --- | --- | --- |
| dev | 7 days | 1 day | None (`dr_region: null`) |
| uat | 14 days | 7 days | None (`dr_region: null`) |
| prod | 35 days | 30 days | Required (`eu-central-1` by default) |

The catalog also defines the maximum Vault Lock retention (3650 days),
COMPLIANCE cooling-off period (3 days), additional rules (empty by default),
continuous backup (disabled, retention of 7/14/35 days in dev/uat/prod), and
restore testing (disabled, Saturday at 03:00 UTC, 480-minute start window,
24-hour validation window).
Default restore types are DynamoDB, EBS, RDS, S3 and EFS.
Alerting and Coverage are enabled by default; Coverage discovers DynamoDB
tables and S3 general purpose buckets with the configured snapshot-age policy.

| Coverage policy | dev | uat | prod |
| --- | --- | --- | --- |
| Maximum snapshot age | 48 hours | 36 hours | 24 hours |
| Freshness tolerance | 4 hours | 2 hours | 1 hour |
| Initial grace | 72 hours | 48 hours | 24 hours |
| Reminder interval | 48 hours | 24 hours | 24 hours |
| Scan interval | 1 hour | 30 minutes | 15 minutes |

Backups remain daily at 01:00 UTC in every environment, with a 480-minute
start window. GOVERNANCE lock, backup-failure alerts and KMS-deletion alerts
remain enabled. Non-production reduces retention, scan frequency and alert
sensitivity; it retains less recovery history and can report coverage gaps later.
Production policy is unchanged. Copy retention applies only when DR is enabled;
PITR retention applies only when continuous backup is enabled.

## Defaults and overrides

Each policy input defaults to null. An explicit non-null consumer value wins
over the selected YAML tier. False and empty lists are explicit overrides.
Lists replace the catalog list; `coverage_policy` replaces the whole object.
Invalid overrides fail through the original modules' validation, not a fallback.

| Policy group | Override inputs |
| --- | --- |
| Snapshot and DR | `backup_schedule`, `backup_window_minutes`, `retention_days`, `copy_retention_days`, `dr_region` |
| Vault Lock | `vault_lock_mode`, `vault_lock_min_retention_days`, `vault_lock_max_retention_days`, `vault_lock_changeable_for_days` |
| Additional rules | `default_plan_additional_rules` |
| Continuous backup | `enable_continuous_backup`, `continuous_retention_days` |
| Restore testing | `enable_restore_testing`, `restore_testing_resource_types`, `restore_testing_schedule`, `restore_testing_start_window`, `restore_testing_max_duration` |
| Alerting and Coverage | `enable_alerting`, `enable_backup_failure_alerts`, `enable_kms_deletion_alert`, `enable_backup_coverage`, `coverage_resource_types`, `coverage_policy` |

Use `enable_alerting = false` to disable the internal Alerting instance and
its Coverage scanner without disabling Backup. Use
`enable_backup_coverage = false` for event-only alerting.
Disabled alerting requires no notification or coverage inputs.
Do not pass old consumer defaults unintentionally: omit policy arguments or
pass null when the YAML default should apply.

### Override precedence and units

Add overrides to the same outer module call, not to a second Backup or Alerting
instance. The following assignment uses the environment's retention:

```hcl
retention_days = null
```

Alternatively, omit `retention_days` entirely. A non-null value replaces the
catalog value for that input only. Changing `retention_days` does not also
change `copy_retention_days`, PITR retention or the Vault Lock minimum.
For example, add these compatible overrides to use 35-day snapshots and copies:

```hcl
retention_days                = 35
copy_retention_days           = 35
vault_lock_min_retention_days = 30
vault_lock_max_retention_days = 400
```

If PITR is also enabled, its retention must fit the same primary vault bounds.
All snapshot, additional-rule, PITR and copy retentions must fit their
applicable Vault Lock bounds. The original modules reject incompatible values.

Retention and cooling-off inputs use days. Backup and restore start windows
use minutes; restore validation duration uses hours. Coverage age, tolerance,
grace and reminder inputs use seconds. Cron examples in this guide use UTC.

### Use Vault Lock COMPLIANCE

The default mode is GOVERNANCE. To opt into COMPLIANCE, add:

```hcl
vault_lock_mode                = "COMPLIANCE"
vault_lock_changeable_for_days = 7
```

This sets a seven-day initial changeable period. Passing only
`vault_lock_mode = "COMPLIANCE"` uses the catalog period of three days.
The mode applies to the primary vault and the DR vault when DR is enabled.
Other policy values remain unchanged unless explicitly overridden.
`vault_lock_changeable_for_days` has no effect in GOVERNANCE mode.

After the initial period, the COMPLIANCE lock is immutable. Changing the
configuration back to GOVERNANCE or removing the module cannot undo that lock.
Review existing vault locks, a saved plan and retention compatibility before
apply. Do not treat a successful mocked test as approval for this transition.

### Alerting and Coverage switches

| Override | Result |
| --- | --- |
| `enable_alerting = false` | Disable Alerting and Coverage; keep Backup |
| `enable_backup_coverage = false` | Disable the scanner; keep the topic and enabled event alerts |
| `enable_backup_failure_alerts = false` | Disable backup-failure event alerts only |
| `enable_kms_deletion_alert = false` | Disable KMS-deletion event alerts only |

To change Coverage policy, pass all five fields. The object replaces the YAML
object; it is not a partial merge:

```hcl
coverage_policy = {
  max_backup_age_seconds      = 172800
  freshness_tolerance_seconds = 14400
  initial_grace_seconds       = 259200
  reminder_interval_seconds   = 172800
  schedule                    = "rate(1 hour)"
}
```

### Optional continuous backup and restore testing

Both features are disabled in every standard tier. For supported S3 continuous
backup, add dedicated selectors and an explicit retention:

```hcl
enable_continuous_backup         = true
continuous_backup_selection_tags = { backup-pitr = "orders-s3" }
continuous_retention_days        = 35
```

Only tag resources intended for continuous backup. DynamoDB PITR is not enabled
by these inputs; configure it on the DynamoDB workload.

To enable S3 restore testing with a two-hour start window and six-hour validation
window, add:

```hcl
enable_restore_testing         = true
restore_testing_resource_types = ["S3"]
restore_testing_start_window   = 120
restore_testing_max_duration   = 6
```

The catalog's Saturday schedule still applies. Snapshot selectors must satisfy
the original module's restore-testing restrictions. Review the resources and
costs of real restores before activation.

## Workload-owned inputs

- `selection_tags` selects snapshots using the original OR semantics.
- `continuous_backup_selection_tags` supplies dedicated tags when PITR is
  enabled. DynamoDB PITR remains native caller configuration.
- `coverage_expected_resource_tags` supplies independent AND inventory tags;
  it is required only when Alerting and Coverage are both enabled.
- `additional_kms_key_ids` adds workload keys to the primary and DR backup
  keys assembled inside the wrapper. IDs are compacted and deduplicated.
  Do not reference this wrapper's own key outputs in its inputs: that creates
  a dependency cycle.
- `email_endpoints` comes from the consumer. Secret retrieval and any
  deliberate declassification remain in the consumer, not this library.
- `tags` is forwarded unchanged; no Product or Environment tags are injected.

Multiple snapshot tags are supported independently of Coverage tags; identical
maps do not prove identical scopes. Scanner infrastructure must not match the
expected workload tags, including inherited provider tags.
The source module retains its selector restrictions when restore testing is
enabled. Service opt-in, workload identity, providers and credentials remain
caller responsibilities.

## Usage

### Prerequisites

Requires Terraform >= 1.14.3, AWS provider >= 5.72.0 and < 6, and Archive provider
>= 2.4.0 and < 3. The caller owns credentials, remote state with locking,
workload tags, service prerequisites and unique prefixes. Use separate
production and non-production roots and state.

The source modules currently require AWS provider 5. Use this wrapper in a
separate Terraform root from IDVH modules that require AWS provider 6.
Aliases cannot select different versions of the same provider in one root.
Provider upgrades belong in the source library, not a local fork.

Replace `<VERIFIED_COMMIT_SHA>` with an immutable published commit that passed
the required checks. No release or successful AWS deployment is implied.
Set `env` to the deployment environment (`dev`, `uat` or `prod`), not `nonprod`.
One module call composes Backup, Alerting and Coverage. Omit policy inputs to
use the selected environment defaults.

The examples below are alternatives for separate environment roots. They use
consumer-owned variables for recipients, workload KMS keys and infrastructure
tags. Define those variables in the consumer; they are not catalog defaults.

### Development or UAT

With DR disabled, pass the primary provider as both aliases. For UAT, change
`env` to `"uat"` and use the UAT workload prefix and tag values.

```hcl
provider "aws" {
  region = "eu-south-1"
}

module "backup" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/aws-backup?ref=<VERIFIED_COMMIT_SHA>"

  providers = {
    aws    = aws
    aws.dr = aws
  }

  product_name       = "aws-backup"
  env                = "dev"
  idvh_resource_tier = "standard"
  aws_region         = "eu-south-1"
  solution_prefix    = "orders-dev-eu-south-1"
  selection_tags                  = { backup-workload = "orders-dev" }
  coverage_expected_resource_tags = { expected-workload = "orders-dev" }
  additional_kms_key_ids           = var.workload_kms_key_ids
  email_endpoints                  = var.backup_email_endpoints
  tags                             = var.tags
}
```

The workload must carry the appropriate snapshot and Coverage tags. The
wrapper does not tag workloads, and the two selectors are intentionally
independent. SNS email recipients must confirm their subscriptions.

### Production with DR

```hcl
provider "aws" {
  region = "eu-south-1"
}

provider "aws" {
  alias  = "dr"
  region = "eu-central-1"
}

module "backup" {
  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/aws-backup?ref=<VERIFIED_COMMIT_SHA>"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  product_name       = "aws-backup"
  env                = "prod"
  idvh_resource_tier = "standard"
  aws_region         = "eu-south-1"
  solution_prefix    = "orders-prod-eu-south-1"

  selection_tags                  = { backup-workload = "orders-prod" }
  coverage_expected_resource_tags = { expected-workload = "orders-prod" }
  additional_kms_key_ids           = var.workload_kms_key_ids
  email_endpoints                  = var.backup_email_endpoints
  tags                             = var.tags
}
```

Production additionally requires a same-account `aws.dr` provider in a different
region. Pass the caller's alias as `aws.dr`; it must match the effective catalog
or override `dr_region`. The production catalog supplies `eu-central-1`, so no
region override is needed when that is the caller's DR provider region.
Including the DR key in the filter does not make the primary-region EventBridge
instance observe DR-region events.

The wrapper forwards resource prefixes unchanged and leaves generated-name
validation to the original modules. `idvh_tier_config` exposes the selected YAML;
`effective_config` exposes the policy after consumer overrides.
Vault, plan, key, topic and scanner outputs remain available. Alerting outputs
are null when alerting is disabled; PITR and restore outputs are null when
those features are disabled.

## Migrating the existing two-module consumer

Keep one outer module call, using the existing backup enable/disable condition:
`count = var.token_backup == null ? 0 : 1`. Preserve the resource prefix,
selection tags, recipients and probe dependencies.
Pass only workload-owned values and intentional policy overrides.
Replace the former alerting key list with
`additional_kms_key_ids = [aws_kms_key.dynamo_db.key_id]`; the wrapper already
adds its own primary and DR keys.
Keep existing feature flags as explicit overrides during migration when their
values differ from the catalog.

The following call uses the existing consumer's providers, selectors, recipient
lookup and probe dependencies. Its policy inputs are omitted deliberately so
the selected environment supplies defaults. The consumer must supply non-empty
Coverage tags when Coverage is enabled, even if its former optional coverage
object is absent.

```hcl
module "token_backup_defaults" {
  count = var.token_backup == null ? 0 : 1

  source = "git::https://github.com/pagopa/technology-aws-modules.git//IDVH/aws-backup?ref=<VERIFIED_COMMIT_SHA>"

  providers = {
    aws    = aws
    aws.dr = aws.eu-central-1
  }

  product_name       = "aws-backup"
  env                = var.environment
  idvh_resource_tier = "standard"
  solution_prefix    = "${local.project}-token-backup"
  aws_region         = var.aws_region

  selection_tags                  = local.token_backup_selection_tags
  coverage_expected_resource_tags = local.token_backup_expected_tags
  additional_kms_key_ids           = [aws_kms_key.dynamo_db.key_id]

  email_endpoints = [
    nonsensitive(
      jsondecode(
        data.aws_secretsmanager_secret_version.email_operation_lt.secret_string
      )["email"]
    )
  ]

  tags = var.tags

  depends_on = [
    aws_s3_bucket_notification.backup_test,
    aws_s3_object.backup_test_probe,
  ]
}
```

Only the notification address is deliberately declassified, not the secret
payload. Keep secret retrieval and state security in the consumer.
To retain legacy opt-out behavior during migration, explicitly pass
`enable_alerting = var.token_backup.enable_alerting` and
`enable_backup_coverage = var.token_backup.coverage != null`.
Those overrides take precedence over the YAML feature defaults.

Using `token_backup_defaults` as the new outer module name, the consumer can
declare the following address migrations for existing counted instances:

```hcl
moved {
  from = module.token_backup[0]
  to   = module.token_backup_defaults[0].module.backup
}

moved {
  from = module.backup_alerting[0]
  to   = module.token_backup_defaults[0].module.alerting[0]
}
```

These are consumer-owned examples, not state changes performed by this library.
They apply only when the old addresses match and the destination instances
exist. Review a saved plan before apply; migration alone must not replace vaults
or keys. Changing flags or retention at the same time can introduce real
infrastructure changes. COMPLIANCE lock becomes immutable after cooling-off.
Existing recovery points are not promised to adopt a new retention policy.
Review the saved plan and existing vault locks before reducing non-production
retention or lock minima. Restoring the old defaults cannot recover data already
expired under a shorter retention policy.

The consumer still owns `depends_on` for probe objects and bucket notifications.
With one wrapper, those dependencies gate the whole composed instance.

## Validation and readiness

```bash
terraform fmt -check -recursive IDVH/aws-backup
bash IDVH/aws-backup/terraform.sh --module-dir IDVH/aws-backup/tests/fixtures/consumer
terraform -chdir=IDVH/aws-backup init -backend=false
terraform -chdir=IDVH/aws-backup test
```

Implementation, runtime tests and advanced features remain owned by the
[source library](https://github.com/pagopa/eng-cloud-strategy-hub/tree/d30c3641dcb68628d9a67f1807ec4c06f3772064/terraform/aws/modules).
The tests here cover the wrapper's catalog integration and input contract.
The consumer fixture supplies provider aliases for static validation; direct
validation of an unconfigured module with `aws.dr` cannot resolve that alias.
Pre-commit validates wrapper changes through this fixture with a read-only
dependency lockfile.
It pins AWS 5.72.0 and Archive 2.4.0 to exercise the minimum provider composition.
Mocked Terraform applies do not contact AWS and do not certify recoverability,
IAM authorization, regional service behavior or email delivery.

Before production: review a saved non-production plan, confirm SNS subscriptions,
verify backup and copy jobs, exercise missing/stale coverage alerts and perform
a real restore. Coverage thresholds measure snapshot creation age, not exact
workload RPO or successful recovery. Do not apply a production plan without
review and approval.

When upgrading the source library, update both Git refs together and rerun the
wrapper tests. Terraform downloads dependencies under `.terraform/`; these
generated downloads are not authored module copies and must not be committed.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.4.0, < 3.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.72.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alerting"></a> [alerting](#module\_alerting) | git::https://github.com/pagopa/eng-cloud-strategy-hub.git//terraform/aws/modules/terraform-aws-backup-alerting | d30c3641dcb68628d9a67f1807ec4c06f3772064 |
| <a name="module_backup"></a> [backup](#module\_backup) | git::https://github.com/pagopa/eng-cloud-strategy-hub.git//terraform/aws/modules/terraform-aws-backup | d30c3641dcb68628d9a67f1807ec4c06f3772064 |
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_data.catalog](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Primary region matching the caller's aws provider. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Catalog environment: dev, uat or prod. | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Catalog name, independent of the workload name. | `string` | n/a | yes |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | Snapshot selection tags forwarded unchanged to Backup, where multiple tags match with OR semantics. | `map(string)` | n/a | yes |
| <a name="input_solution_prefix"></a> [solution\_prefix](#input\_solution\_prefix) | Unique resource prefix forwarded unchanged. Source modules enforce their generated-name limits. | `string` | n/a | yes |
| <a name="input_additional_kms_key_ids"></a> [additional\_kms\_key\_ids](#input\_additional\_kms\_key\_ids) | Workload key IDs or ARNs to monitor in addition to the backup primary and DR keys. | `list(string)` | `[]` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Override the catalog snapshot cron schedule. | `string` | `null` | no |
| <a name="input_backup_window_minutes"></a> [backup\_window\_minutes](#input\_backup\_window\_minutes) | Override the catalog snapshot start window in whole minutes. | `number` | `null` | no |
| <a name="input_continuous_backup_selection_tags"></a> [continuous\_backup\_selection\_tags](#input\_continuous\_backup\_selection\_tags) | Dedicated tags for supported continuous-backup resources. Required when PITR is enabled. | `map(string)` | `null` | no |
| <a name="input_continuous_retention_days"></a> [continuous\_retention\_days](#input\_continuous\_retention\_days) | Override the catalog PITR retention, independently of snapshot retention. | `number` | `null` | no |
| <a name="input_copy_retention_days"></a> [copy\_retention\_days](#input\_copy\_retention\_days) | Override catalog DR copy retention in whole days. | `number` | `null` | no |
| <a name="input_coverage_expected_resource_tags"></a> [coverage\_expected\_resource\_tags](#input\_coverage\_expected\_resource\_tags) | Independent coverage inventory tags, matched with AND semantics. Required when coverage is enabled. | `map(string)` | `{}` | no |
| <a name="input_coverage_policy"></a> [coverage\_policy](#input\_coverage\_policy) | Replace the catalog coverage policy; the whole object is overridden, not merged. | <pre>object({<br/>    max_backup_age_seconds      = number<br/>    freshness_tolerance_seconds = number<br/>    initial_grace_seconds       = number<br/>    reminder_interval_seconds   = number<br/>    schedule                    = string<br/>  })</pre> | `null` | no |
| <a name="input_coverage_resource_types"></a> [coverage\_resource\_types](#input\_coverage\_resource\_types) | Replace catalog coverage inventory types: DynamoDB and/or S3. | `set(string)` | `null` | no |
| <a name="input_default_plan_additional_rules"></a> [default\_plan\_additional\_rules](#input\_default\_plan\_additional\_rules) | Replace the catalog additional rules. An empty list explicitly disables catalog additional rules. | <pre>list(object({<br/>    rule_name               = string<br/>    schedule                = string<br/>    start_window            = optional(number)<br/>    completion_window       = optional(number)<br/>    cold_storage_after      = optional(number, 0)<br/>    delete_after            = number<br/>    recovery_point_tags     = optional(map(string), {})<br/>    copy_to_dr              = optional(bool)<br/>    copy_cold_storage_after = optional(number)<br/>    copy_delete_after       = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_dr_region"></a> [dr\_region](#input\_dr\_region) | Override the catalog DR region. Must match aws.dr and differ from aws\_region in prod. | `string` | `null` | no |
| <a name="input_email_endpoints"></a> [email\_endpoints](#input\_email\_endpoints) | Backup notification recipients; each must confirm its SNS subscription. | `list(string)` | `[]` | no |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | Override catalog alerting activation. False disables Alerting and its Coverage scanner. | `bool` | `null` | no |
| <a name="input_enable_backup_coverage"></a> [enable\_backup\_coverage](#input\_enable\_backup\_coverage) | Override catalog coverage activation. False retains event-only alerting. | `bool` | `null` | no |
| <a name="input_enable_backup_failure_alerts"></a> [enable\_backup\_failure\_alerts](#input\_enable\_backup\_failure\_alerts) | Override catalog backup failure event alerts. | `bool` | `null` | no |
| <a name="input_enable_continuous_backup"></a> [enable\_continuous\_backup](#input\_enable\_continuous\_backup) | Override catalog continuous-backup activation. False is an explicit override. | `bool` | `null` | no |
| <a name="input_enable_kms_deletion_alert"></a> [enable\_kms\_deletion\_alert](#input\_enable\_kms\_deletion\_alert) | Override catalog key deletion event alerts. | `bool` | `null` | no |
| <a name="input_enable_restore_testing"></a> [enable\_restore\_testing](#input\_enable\_restore\_testing) | Override catalog restore-testing activation. False is an explicit override. | `bool` | `null` | no |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | Policy tier in the selected catalog. | `string` | `"standard"` | no |
| <a name="input_restore_testing_max_duration"></a> [restore\_testing\_max\_duration](#input\_restore\_testing\_max\_duration) | Override the catalog restore validation duration in hours. | `number` | `null` | no |
| <a name="input_restore_testing_resource_types"></a> [restore\_testing\_resource\_types](#input\_restore\_testing\_resource\_types) | Replace catalog restore-testing resource types. | `list(string)` | `null` | no |
| <a name="input_restore_testing_schedule"></a> [restore\_testing\_schedule](#input\_restore\_testing\_schedule) | Override the catalog restore-testing cron schedule. | `string` | `null` | no |
| <a name="input_restore_testing_start_window"></a> [restore\_testing\_start\_window](#input\_restore\_testing\_start\_window) | Override the catalog restore-testing start window in minutes. | `number` | `null` | no |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Override catalog snapshot retention in whole days. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Infrastructure tags forwarded unchanged. Scanner infrastructure must not match the expected workload inventory. | `map(string)` | `{}` | no |
| <a name="input_vault_lock_changeable_for_days"></a> [vault\_lock\_changeable\_for\_days](#input\_vault\_lock\_changeable\_for\_days) | Override the catalog COMPLIANCE cooling-off period. | `number` | `null` | no |
| <a name="input_vault_lock_max_retention_days"></a> [vault\_lock\_max\_retention\_days](#input\_vault\_lock\_max\_retention\_days) | Override the catalog maximum Vault Lock retention. | `number` | `null` | no |
| <a name="input_vault_lock_min_retention_days"></a> [vault\_lock\_min\_retention\_days](#input\_vault\_lock\_min\_retention\_days) | Override the catalog minimum Vault Lock retention for both vaults. | `number` | `null` | no |
| <a name="input_vault_lock_mode"></a> [vault\_lock\_mode](#input\_vault\_lock\_mode) | Override catalog Vault Lock mode. COMPLIANCE is explicit opt-in and becomes immutable. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arn"></a> [backup\_plan\_arn](#output\_backup\_plan\_arn) | Scheduled snapshot backup plan ARN. |
| <a name="output_continuous_plan_id"></a> [continuous\_plan\_id](#output\_continuous\_plan\_id) | Continuous backup plan ID, or null when disabled. |
| <a name="output_coverage_lambda_function_arn"></a> [coverage\_lambda\_function\_arn](#output\_coverage\_lambda\_function\_arn) | Coverage scanner ARN, or null when the catalog disables it. |
| <a name="output_dr_kms_key_id"></a> [dr\_kms\_key\_id](#output\_dr\_kms\_key\_id) | DR vault KMS key ID, or null outside production. |
| <a name="output_dr_vault_arn"></a> [dr\_vault\_arn](#output\_dr\_vault\_arn) | DR vault ARN, or null outside production. |
| <a name="output_effective_config"></a> [effective\_config](#output\_effective\_config) | Catalog policy after explicit consumer overrides. |
| <a name="output_idvh_tier_config"></a> [idvh\_tier\_config](#output\_idvh\_tier\_config) | Selected catalog policy. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | Primary vault KMS key ID. |
| <a name="output_restore_testing_plan_arn"></a> [restore\_testing\_plan\_arn](#output\_restore\_testing\_plan\_arn) | Restore testing plan ARN, or null when disabled. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | Encrypted backup notification topic ARN. |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | Primary backup vault ARN. |
| <a name="output_vault_name"></a> [vault\_name](#output\_vault\_name) | Primary backup vault name. |
<!-- END_TF_DOCS -->
