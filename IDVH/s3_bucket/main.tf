module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "s3_bucket"
}

data "aws_caller_identity" "current" {}

locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "append_account_id_suffix",
    "force_destroy",
    "versioning_enabled",
    "object_ownership",
    "block_public_acls",
    "block_public_policy",
    "ignore_public_acls",
    "restrict_public_buckets",
    "attach_deny_insecure_transport_policy",
    "attach_require_latest_tls_policy",
    "sse_algorithm",
    "bucket_key_enabled",
    "lifecycle_rule",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  effective_name_prefix              = try(tostring(local.idvh_config.name_prefix), null)
  effective_name_suffix              = try(tostring(local.idvh_config.name_suffix), null)
  effective_append_account_id_suffix = tobool(local.idvh_config.append_account_id_suffix)
  effective_force_destroy            = coalesce(var.force_destroy, tobool(local.idvh_config.force_destroy))
  effective_object_ownership         = tostring(local.idvh_config.object_ownership)
  effective_versioning_enabled       = tobool(local.idvh_config.versioning_enabled)
  effective_block_public_acls        = tobool(local.idvh_config.block_public_acls)
  effective_block_public_policy      = tobool(local.idvh_config.block_public_policy)
  effective_ignore_public_acls       = tobool(local.idvh_config.ignore_public_acls)
  effective_restrict_public_buckets  = tobool(local.idvh_config.restrict_public_buckets)

  effective_attach_deny_insecure_transport_policy = tobool(local.idvh_config.attach_deny_insecure_transport_policy)
  effective_attach_require_latest_tls_policy      = tobool(local.idvh_config.attach_require_latest_tls_policy)
  effective_sse_algorithm                         = tostring(local.idvh_config.sse_algorithm)
  effective_bucket_key_enabled                    = tobool(local.idvh_config.bucket_key_enabled)
  effective_lifecycle_rule                        = var.lifecycle_rule != null ? var.lifecycle_rule : local.idvh_config.lifecycle_rule

  normalized_name = lower(replace(var.name, "_", "-"))

  bucket_name_parts = compact([
    local.effective_name_prefix,
    local.normalized_name,
    local.effective_name_suffix,
    local.effective_append_account_id_suffix ? data.aws_caller_identity.current.account_id : null,
  ])

  bucket_name_composed = substr(join("-", local.bucket_name_parts), 0, 63)
  bucket_name          = replace(local.bucket_name_composed, "/-+$/", "")
}

module "s3_bucket_raw" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=b040965a526e22a78784840c2f2ae384f2a8e4ef"

  bucket        = local.bucket_name
  acl           = null
  force_destroy = local.effective_force_destroy

  control_object_ownership = true
  object_ownership         = local.effective_object_ownership

  versioning = {
    enabled = local.effective_versioning_enabled
  }

  block_public_acls       = local.effective_block_public_acls
  block_public_policy     = local.effective_block_public_policy
  ignore_public_acls      = local.effective_ignore_public_acls
  restrict_public_buckets = local.effective_restrict_public_buckets

  attach_deny_insecure_transport_policy = local.effective_attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy      = local.effective_attach_require_latest_tls_policy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : local.effective_sse_algorithm
        kms_master_key_id = var.kms_key_arn
      }
      bucket_key_enabled = local.effective_bucket_key_enabled
    }
  }

  lifecycle_rule = local.effective_lifecycle_rule

  tags = merge(
    var.tags,
    {
      Name = local.bucket_name
    }
  )
}
