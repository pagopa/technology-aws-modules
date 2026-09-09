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
}

check "s3_bucket_yaml_required_keys" {
  assert {
    condition     = length(local.missing_tier_keys) == 0
    error_message = "Invalid s3_bucket tier YAML. Missing required keys: [${join(", ", tolist(local.missing_tier_keys))}]"
  }
}

check "s3_bucket_yaml_types" {
  assert {
    condition = (
      (can(local.idvh_config.name_prefix) ? can(tostring(local.idvh_config.name_prefix)) : true) &&
      (can(local.idvh_config.name_suffix) ? can(tostring(local.idvh_config.name_suffix)) : true) &&
      can(tobool(local.idvh_config.append_account_id_suffix)) &&
      can(tobool(local.idvh_config.force_destroy)) &&
      can(tobool(local.idvh_config.versioning_enabled)) &&
      can(tostring(local.idvh_config.object_ownership)) &&
      can(tobool(local.idvh_config.block_public_acls)) &&
      can(tobool(local.idvh_config.block_public_policy)) &&
      can(tobool(local.idvh_config.ignore_public_acls)) &&
      can(tobool(local.idvh_config.restrict_public_buckets)) &&
      can(tobool(local.idvh_config.attach_deny_insecure_transport_policy)) &&
      can(tobool(local.idvh_config.attach_require_latest_tls_policy)) &&
      can(tostring(local.idvh_config.sse_algorithm)) &&
      can(tobool(local.idvh_config.bucket_key_enabled)) &&
      can([for rule in local.idvh_config.lifecycle_rule : rule])
    )

    error_message = "Invalid s3_bucket tier YAML types. Check booleans, object_ownership, sse_algorithm and lifecycle_rule values."
  }
}

check "s3_bucket_yaml_values" {
  assert {
    condition = (
      contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], try(local.idvh_config.object_ownership, "")) &&
      (var.kms_key_arn != null || contains(["AES256", "aws:kms"], try(local.idvh_config.sse_algorithm, "")))
    )

    error_message = "Invalid s3_bucket tier YAML values. object_ownership must be one of BucketOwnerEnforced/BucketOwnerPreferred/ObjectWriter and sse_algorithm must be AES256 or aws:kms when kms_key_arn is not provided."
  }
}
