module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "s3_bucket"
}

data "aws_caller_identity" "current" {}

locals {
  normalized_name = lower(replace(var.name, "_", "-"))

  bucket_name_parts = compact([
    try(local.idvh_config.name_prefix, null),
    local.normalized_name,
    try(local.idvh_config.name_suffix, null),
    try(local.idvh_config.append_account_id_suffix, false) ? data.aws_caller_identity.current.account_id : null,
  ])

  bucket_name           = replace(substr(join("-", local.bucket_name_parts), 0, 63), "/-+$/", "")
  bucket_force_destroy  = var.force_destroy != null ? var.force_destroy : try(local.idvh_config.force_destroy, false)
  bucket_lifecycle_rule = var.lifecycle_rule != null ? var.lifecycle_rule : try(local.idvh_config.lifecycle_rule, [])
  bucket_sse_algorithm  = var.kms_key_arn != null ? "aws:kms" : try(local.idvh_config.sse_algorithm, "AES256")
}

module "s3_bucket_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/releases/tag/v5.10.0
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/commit/b040965a526e22a78784840c2f2ae384f2a8e4ef
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=b040965a526e22a78784840c2f2ae384f2a8e4ef"

  bucket        = local.bucket_name
  acl           = null
  force_destroy = local.bucket_force_destroy

  control_object_ownership = true
  object_ownership         = try(local.idvh_config.object_ownership, "BucketOwnerEnforced")

  versioning = {
    enabled = try(local.idvh_config.versioning_enabled, true)
  }

  block_public_acls       = try(local.idvh_config.block_public_acls, true)
  block_public_policy     = try(local.idvh_config.block_public_policy, true)
  ignore_public_acls      = try(local.idvh_config.ignore_public_acls, true)
  restrict_public_buckets = try(local.idvh_config.restrict_public_buckets, true)

  attach_deny_insecure_transport_policy = try(local.idvh_config.attach_deny_insecure_transport_policy, true)
  attach_require_latest_tls_policy      = try(local.idvh_config.attach_require_latest_tls_policy, true)

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = local.bucket_sse_algorithm
        kms_master_key_id = var.kms_key_arn
      }
      bucket_key_enabled = try(local.idvh_config.bucket_key_enabled, true)
    }
  }

  lifecycle_rule = local.bucket_lifecycle_rule

  tags = merge(
    var.tags,
    {
      Name = local.bucket_name
    }
  )
}
