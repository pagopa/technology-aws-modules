module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "dynamodb"
}

locals {
  table_name_parts = compact([
    try(local.idvh_config.name_prefix, null),
    var.name,
    try(local.idvh_config.name_suffix, null),
  ])

  table_name = join("-", local.table_name_parts)

  effective_point_in_time_recovery_enabled = var.point_in_time_recovery_enabled != null ? var.point_in_time_recovery_enabled : local.idvh_config.point_in_time_recovery_enabled
  effective_deletion_protection_enabled    = var.deletion_protection_enabled != null ? var.deletion_protection_enabled : local.idvh_config.deletion_protection_enabled
}

resource "aws_dynamodb_table" "this" {
  name      = local.table_name
  hash_key  = var.hash_key
  range_key = var.range_key

  billing_mode = local.idvh_config.billing_mode
  table_class  = local.idvh_config.table_class

  read_capacity  = local.idvh_config.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = local.idvh_config.billing_mode == "PROVISIONED" ? var.write_capacity : null

  stream_enabled   = local.idvh_config.stream_enabled
  stream_view_type = local.idvh_config.stream_enabled ? local.idvh_config.stream_view_type : null

  deletion_protection_enabled = local.effective_deletion_protection_enabled

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery {
    enabled = local.effective_point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = local.idvh_config.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  dynamic "ttl" {
    for_each = local.idvh_config.ttl_enabled ? [1] : []

    content {
      attribute_name = local.idvh_config.ttl_attribute_name
      enabled        = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = local.table_name
    }
  )
}
