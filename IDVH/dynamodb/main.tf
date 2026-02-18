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

  hash_key = var.hash_key
  
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = local.effective_server_side_encryption_kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}
