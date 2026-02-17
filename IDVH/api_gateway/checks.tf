locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "protocol_type",
    "disable_execute_api_endpoint",
    "stage_name",
    "auto_deploy",
    "access_logs",
  ])

  required_access_log_keys = toset([
    "enabled",
    "retention_in_days",
  ])

  missing_tier_keys       = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))
  missing_access_log_keys = can(local.idvh_config.access_logs) ? setsubtract(local.required_access_log_keys, toset(keys(local.idvh_config.access_logs))) : local.required_access_log_keys
}

check "api_gateway_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_access_log_keys) == 0
    )

    error_message = "Invalid api_gateway tier YAML. Missing required keys. tier: [${join(", ", tolist(local.missing_tier_keys))}] access_logs: [${join(", ", tolist(local.missing_access_log_keys))}]"
  }
}

check "api_gateway_yaml_types" {
  assert {
    condition = (
      can(tostring(local.idvh_config.protocol_type)) &&
      can(tobool(local.idvh_config.disable_execute_api_endpoint)) &&
      can(tostring(local.idvh_config.stage_name)) &&
      can(tobool(local.idvh_config.auto_deploy)) &&
      can(tobool(local.idvh_config.access_logs.enabled)) &&
      can(tonumber(local.idvh_config.access_logs.retention_in_days)) &&
      (can(local.idvh_config.access_logs.format) ? can(tostring(local.idvh_config.access_logs.format)) : true)
    )

    error_message = "Invalid api_gateway tier YAML types. Check protocol_type, stage_name, booleans and access_logs values."
  }
}

check "api_gateway_yaml_values" {
  assert {
    condition = (
      upper(local.idvh_config.protocol_type) == "HTTP" &&
      length(trimspace(local.effective_stage_name)) > 0 &&
      local.idvh_config.access_logs.retention_in_days > 0 &&
      (
        local.access_logs_enabled ?
        length(trimspace(local.effective_access_log_format)) > 0 :
        true
      )
    )

    error_message = "Invalid api_gateway tier YAML values. protocol_type must be HTTP, stage_name must be non-empty and access log settings must be valid."
  }
}
