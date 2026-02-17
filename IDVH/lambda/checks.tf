check "lambda_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_code_bucket_keys) == 0 &&
      length(local.missing_deploy_role_keys) == 0
    )

    error_message = "Invalid lambda tier YAML. Missing required keys. tier: [${join(", ", tolist(local.missing_tier_keys))}] code_bucket: [${join(", ", tolist(local.missing_code_bucket_keys))}] deploy_role: [${join(", ", tolist(local.missing_deploy_role_keys))}]"
  }
}

check "lambda_yaml_types" {
  assert {
    condition = (
      can(tostring(local.idvh_config.runtime)) &&
      can(tostring(local.idvh_config.handler)) &&
      can([for a in local.idvh_config.architectures : tostring(a)]) &&
      can(tonumber(local.idvh_config.memory_size)) &&
      can(tonumber(local.idvh_config.timeout)) &&
      can(tobool(local.idvh_config.publish)) &&
      can(tobool(local.idvh_config.ignore_source_code_hash)) &&
      can(tonumber(local.idvh_config.cloudwatch_logs_retention_in_days)) &&
      can(tobool(local.idvh_config.code_bucket.enabled)) &&
      can(tostring(local.idvh_config.code_bucket.idvh_resource_tier)) &&
      can(tostring(local.idvh_config.code_bucket.name_prefix)) &&
      can(tostring(local.idvh_config.code_bucket.name_suffix)) &&
      can(tobool(local.idvh_config.deploy_role.enabled)) &&
      can([for action in local.idvh_config.deploy_role.lambda_actions : tostring(action)])
    )

    error_message = "Invalid lambda tier YAML types. Check runtime/handler/architectures/memory_size/timeout/publish and nested code_bucket/deploy_role values."
  }
}

check "lambda_yaml_values" {
  assert {
    condition = (
      can(length(local.idvh_config.architectures) > 0) &&
      can(length(local.idvh_config.deploy_role.lambda_actions) > 0) &&
      length(local.idvh_config.architectures) > 0 &&
      length(local.idvh_config.deploy_role.lambda_actions) > 0
    )

    error_message = "Invalid lambda tier YAML values. architectures and deploy_role.lambda_actions must contain at least one value."
  }
}

check "external_code_bucket_inputs" {
  assert {
    condition     = local.effective_create_code_bucket || (var.existing_code_bucket_name != null && var.existing_code_bucket_arn != null)
    error_message = "For tiers with code_bucket.enabled=false, both existing_code_bucket_name and existing_code_bucket_arn are required."
  }
}
