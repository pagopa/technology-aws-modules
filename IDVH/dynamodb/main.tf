module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "dynamodb"
}

locals {
  effective_table_config = {
    table_name                  = var.table_config.table_name
    hash_key                    = var.table_config.hash_key
    range_key                   = var.table_config.range_key
    attributes                  = var.table_config.attributes
    billing_mode                = var.table_config.billing_mode != null ? var.table_config.billing_mode : local.idvh_config.billing_mode
    stream_enabled              = var.table_config.stream_enabled != null ? var.table_config.stream_enabled : local.idvh_config.stream_enabled
    stream_view_type            = var.table_config.stream_view_type != null ? var.table_config.stream_view_type : local.idvh_config.stream_view_type
    ttl_enabled                 = var.table_config.ttl_enabled != null ? var.table_config.ttl_enabled : local.idvh_config.ttl_enabled
    ttl_attribute_name          = var.table_config.ttl_attribute_name != null ? var.table_config.ttl_attribute_name : local.idvh_config.ttl_attribute_name
    deletion_protection_enabled = var.table_config.deletion_protection_enabled != null ? var.table_config.deletion_protection_enabled : local.idvh_config.deletion_protection_enabled
    global_secondary_indexes    = var.table_config.global_secondary_indexes != null ? var.table_config.global_secondary_indexes : local.idvh_config.global_secondary_indexes
    local_secondary_indexes     = var.table_config.local_secondary_indexes != null ? var.table_config.local_secondary_indexes : local.idvh_config.local_secondary_indexes
    replica_regions             = var.table_config.replica_regions != null ? var.table_config.replica_regions : local.idvh_config.replica_regions
  }

  effective_kms_enable_key_rotation = var.kms_enable_key_rotation != null ? var.kms_enable_key_rotation : local.idvh_config.kms_ssm_enable_rotation

  effective_kms_rotation_period_in_days = var.kms_rotation_period_in_days != null ? var.kms_rotation_period_in_days : local.idvh_config.kms_rotation_period_in_days

  effective_point_in_time_recovery = var.enable_point_in_time_recovery != null ? var.enable_point_in_time_recovery : local.idvh_config.enable_point_in_time_recovery

  effective_server_side_encryption_kms_key_arn = var.create_kms_key ? module.kms_table_key[0].aliases[var.kms_alias].target_key_arn : var.server_side_encryption_kms_key_arn

  effective_replica_regions = var.enable_replication ? [
    for replica in local.effective_table_config.replica_regions : merge(
      replica,
      {
        kms_key_arn = (
          lookup(replica, "kms_key_arn", null) != null && length(trimspace(lookup(replica, "kms_key_arn", ""))) > 0
          ? lookup(replica, "kms_key_arn", null)
          : local.effective_server_side_encryption_kms_key_arn
        )
      }
    )
  ] : []
}

module "kms_table_key" {
  count = var.create_kms_key ? 1 : 0
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-kms/releases/tag/v3.0.0
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=8478d2dcaa81d60e6a21adeee4bc428290244f11"

  description             = var.kms_description
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = local.effective_kms_enable_key_rotation
  rotation_period_in_days = local.effective_kms_rotation_period_in_days
  #policy                  = var.policy
  enable_default_policy   = true
  multi_region            = var.enable_replication
  aliases = [var.kms_alias]

  tags = merge(
    var.tags,
    {
      Name = "kms-${local.effective_table_config.table_name}"
    }
  )
}

module "dynamodb_table" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table/releases/tag/v4.0.1
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git?ref=696ceabbfdd49f8246e3d401c035729d60ea6fab"

  name = local.effective_table_config.table_name

  hash_key   = local.effective_table_config.hash_key
  range_key  = local.effective_table_config.range_key
  attributes = local.effective_table_config.attributes

  billing_mode = local.effective_table_config.billing_mode

  stream_enabled   = local.effective_table_config.stream_enabled
  stream_view_type = local.effective_table_config.stream_view_type

  ttl_enabled        = local.effective_table_config.ttl_enabled
  ttl_attribute_name = local.effective_table_config.ttl_attribute_name

  deletion_protection_enabled = local.effective_table_config.deletion_protection_enabled

  replica_regions = local.effective_replica_regions

  global_secondary_indexes = local.effective_table_config.global_secondary_indexes
  local_secondary_indexes  = local.effective_table_config.local_secondary_indexes

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = local.effective_server_side_encryption_kms_key_arn
  point_in_time_recovery_enabled     = local.effective_point_in_time_recovery

  tags = merge(
    var.tags,
    {
      Name = local.effective_table_config.table_name
    }
  )
}
