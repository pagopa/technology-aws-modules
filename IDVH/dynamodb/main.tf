module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "dynamodb"
}

locals {
  effective_kms_enable_key_rotation = var.kms_enable_key_rotation != null ? var.kms_enable_key_rotation : local.idvh_config.kms_ssm_enable_rotation

  effective_kms_rotation_period_in_days = var.kms_rotation_period_in_days != null ? var.kms_rotation_period_in_days : local.idvh_config.kms_rotation_period_in_days

  effective_server_side_encryption_kms_key_arn = var.create_kms_key ? module.kms_table_key[0].aliases[var.kms_alias].target_key_arn : var.server_side_encryption_kms_key_arn

  table_global_secondary_index_arns = {
    for gsi in var.global_secondary_indexes :
    gsi.name => "${module.dynamodb_table.dynamodb_table_arn}/index/${gsi.name}"
  }
}

module "kms_table_key" {
  count = var.create_kms_key ? 1 : 0
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-kms/releases/tag/v3.0.0
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=8478d2dcaa81d60e6a21adeee4bc428290244f11"

  description             = var.kms_description
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = local.effective_kms_enable_key_rotation
  rotation_period_in_days = local.effective_kms_rotation_period_in_days

  aliases = [var.kms_alias]

  tags = merge(
    var.tags,
    {
      Name = "kms-${var.table_name}"
    }
  )
}

module "dynamodb_table" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table/releases/tag/v4.0.1
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git?ref=696ceabbfdd49f8246e3d401c035729d60ea6fab"

  name = var.table_name

  hash_key  = var.hash_key
  range_key = var.range_key

  attributes               = var.attributes
  global_secondary_indexes = var.global_secondary_indexes
  local_secondary_indexes  = var.local_secondary_indexes

  billing_mode = var.billing_mode

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  ttl_attribute_name = var.ttl_attribute_name
  ttl_enabled        = var.ttl_enabled

  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  replica_regions = var.replication_regions

  server_side_encryption_enabled     = var.server_side_encryption_enabled
  server_side_encryption_kms_key_arn = local.effective_server_side_encryption_kms_key_arn

  deletion_protection_enabled = var.deletion_protection_enabled

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}
