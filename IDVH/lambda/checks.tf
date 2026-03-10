locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "runtime",
    "handler",
    "architectures",
    "memory_size",
    "timeout",
    "publish",
    "ignore_source_code_hash",
    "cloudwatch_logs_retention_in_days",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

}

check "lambda_yaml_required_keys" {
  assert {
    condition     = length(local.missing_tier_keys) == 0
    error_message = "Invalid lambda tier YAML. Missing required keys: [${join(", ", tolist(local.missing_tier_keys))}]"
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
      can(tonumber(local.idvh_config.cloudwatch_logs_retention_in_days))
    )

    error_message = "Invalid lambda tier YAML types. Check runtime/handler/architectures/memory_size/timeout/publish/cloudwatch_logs_retention_in_days values."
  }
}

check "lambda_yaml_values" {
  assert {
    condition = (
      can(length(local.idvh_config.architectures) > 0) &&
      length(local.idvh_config.architectures) > 0
    )

    error_message = "Invalid lambda tier YAML values. architectures must contain at least one value."
  }
}
