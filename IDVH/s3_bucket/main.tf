module "idh_loader" {
  source = "../01_idvh_loader"

  product_name      = var.product_name
  env               = var.env
  idh_resource_tier = var.idh_resource_tier
  idh_resource_type = "s3_bucket"
}

data "aws_caller_identity" "current" {}

locals {
  idh_config = module.idh_loader.idh_resource_configuration

  normalized_name = lower(replace(var.name, "_", "-"))

  bucket_name_parts = compact([
    try(local.idh_config.name_prefix, null),
    local.normalized_name,
    try(local.idh_config.name_suffix, null),
    try(local.idh_config.append_account_id_suffix, false) ? data.aws_caller_identity.current.account_id : null,
  ])

  bucket_name_composed = substr(join("-", local.bucket_name_parts), 0, 63)
  bucket_name          = replace(local.bucket_name_composed, "/-+$/", "")

  lifecycle_rule = var.lifecycle_rule != null ? var.lifecycle_rule : try(local.idh_config.lifecycle_rule, [])
}

module "s3_bucket_raw" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=5475b21947c1c895891f1761a70dfe2bb87c3ac6"

  bucket        = local.bucket_name
  acl           = null
  force_destroy = coalesce(var.force_destroy, try(local.idh_config.force_destroy, false))

  control_object_ownership = true
  object_ownership         = try(local.idh_config.object_ownership, "BucketOwnerEnforced")

  versioning = {
    enabled = try(local.idh_config.versioning_enabled, true)
  }

  block_public_acls       = try(local.idh_config.block_public_acls, true)
  block_public_policy     = try(local.idh_config.block_public_policy, true)
  ignore_public_acls      = try(local.idh_config.ignore_public_acls, true)
  restrict_public_buckets = try(local.idh_config.restrict_public_buckets, true)

  attach_deny_insecure_transport_policy = try(local.idh_config.attach_deny_insecure_transport_policy, true)
  attach_require_latest_tls_policy      = try(local.idh_config.attach_require_latest_tls_policy, true)

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : try(local.idh_config.sse_algorithm, "AES256")
        kms_master_key_id = var.kms_key_arn
      }
      bucket_key_enabled = try(local.idh_config.bucket_key_enabled, true)
    }
  }

  lifecycle_rule = local.lifecycle_rule

  tags = merge(
    var.tags,
    {
      Name = local.bucket_name
    }
  )
}
