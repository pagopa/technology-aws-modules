locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "endpoint_configuration",
    "stage_name",
    "xray_tracing_enabled",
    "api_cache_cluster_enabled",
    "api_cache_cluster_size",
    "method_settings",
    "plan",
    "custom_domain",
    "api_authorizer",
    "cloudwatch_logs_retention_in_days",
  ])

  required_endpoint_configuration_keys = toset([
    "types",
    "vpc_endpoint_ids",
  ])

  required_plan_keys = toset([
    "name",
    "throttle_burst_limit",
    "throttle_rate_limit",
    "api_key_name",
  ])

  required_custom_domain_keys = toset([
    "create",
    "domain_name",
    "certificate_arn",
    "api_mapping_key",
  ])

  required_api_authorizer_keys = toset([
    "name",
    "user_pool_arn",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  missing_endpoint_configuration_keys = can(local.idvh_config.endpoint_configuration) ? setsubtract(local.required_endpoint_configuration_keys, toset(keys(local.idvh_config.endpoint_configuration))) : local.required_endpoint_configuration_keys

  missing_plan_keys = can(local.idvh_config.plan) ? setsubtract(local.required_plan_keys, toset(keys(local.idvh_config.plan))) : local.required_plan_keys

  missing_custom_domain_keys = can(local.idvh_config.custom_domain) ? setsubtract(local.required_custom_domain_keys, toset(keys(local.idvh_config.custom_domain))) : local.required_custom_domain_keys

  missing_api_authorizer_keys = can(local.idvh_config.api_authorizer) ? setsubtract(local.required_api_authorizer_keys, toset(keys(local.idvh_config.api_authorizer))) : local.required_api_authorizer_keys
}

check "api_gateway_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_endpoint_configuration_keys) == 0 &&
      length(local.missing_plan_keys) == 0 &&
      length(local.missing_custom_domain_keys) == 0 &&
      length(local.missing_api_authorizer_keys) == 0
    )

    error_message = "Invalid api_gateway tier YAML. Missing required keys. tier: [${join(", ", tolist(local.missing_tier_keys))}] endpoint_configuration: [${join(", ", tolist(local.missing_endpoint_configuration_keys))}] plan: [${join(", ", tolist(local.missing_plan_keys))}] custom_domain: [${join(", ", tolist(local.missing_custom_domain_keys))}] api_authorizer: [${join(", ", tolist(local.missing_api_authorizer_keys))}]"
  }
}

check "api_gateway_yaml_types" {
  assert {
    condition = (
      can([for endpoint_type in local.idvh_config.endpoint_configuration.types : tostring(endpoint_type)]) &&
      can([for vpc_endpoint_id in local.idvh_config.endpoint_configuration.vpc_endpoint_ids : tostring(vpc_endpoint_id)]) &&
      can(tostring(local.idvh_config.stage_name)) &&
      can(tobool(local.idvh_config.xray_tracing_enabled)) &&
      can(tobool(local.idvh_config.api_cache_cluster_enabled)) &&
      can(tonumber(local.idvh_config.api_cache_cluster_size)) &&
      can([for method_setting in local.idvh_config.method_settings : tostring(method_setting.method_path)]) &&
      can(tostring(local.idvh_config.plan.name)) &&
      can(tonumber(local.idvh_config.plan.throttle_burst_limit)) &&
      can(tonumber(local.idvh_config.plan.throttle_rate_limit)) &&
      (local.idvh_config.plan.api_key_name == null || can(tostring(local.idvh_config.plan.api_key_name))) &&
      can(tobool(local.idvh_config.custom_domain.create)) &&
      (local.idvh_config.custom_domain.domain_name == null || can(tostring(local.idvh_config.custom_domain.domain_name))) &&
      (local.idvh_config.custom_domain.certificate_arn == null || can(tostring(local.idvh_config.custom_domain.certificate_arn))) &&
      (local.idvh_config.custom_domain.api_mapping_key == null || can(tostring(local.idvh_config.custom_domain.api_mapping_key))) &&
      (local.idvh_config.api_authorizer.name == null || can(tostring(local.idvh_config.api_authorizer.name))) &&
      (local.idvh_config.api_authorizer.user_pool_arn == null || can(tostring(local.idvh_config.api_authorizer.user_pool_arn))) &&
      can(tonumber(local.idvh_config.cloudwatch_logs_retention_in_days))
    )

    error_message = "Invalid api_gateway tier YAML types. Check endpoint/stage/cache/plan/custom_domain/api_authorizer values."
  }
}

check "api_gateway_yaml_values" {
  assert {
    condition = (
      length(trimspace(local.effective_stage_name)) > 0 &&
      length(local.idvh_config.endpoint_configuration.types) > 0 &&
      alltrue([for endpoint_type in local.idvh_config.endpoint_configuration.types : contains(["EDGE", "REGIONAL", "PRIVATE"], endpoint_type)]) &&
      (contains(local.idvh_config.endpoint_configuration.types, "PRIVATE") ? length(local.effective_endpoint_vpc_endpoint_ids) > 0 : true) &&
      (local.idvh_config.api_cache_cluster_enabled ? local.idvh_config.api_cache_cluster_size > 0 : true) &&
      local.idvh_config.plan.throttle_burst_limit >= 0 &&
      local.idvh_config.plan.throttle_rate_limit >= 0 &&
      local.idvh_config.cloudwatch_logs_retention_in_days > 0 &&
      (
        local.effective_create_custom_domain_name ?
        local.effective_custom_domain_name != null &&
        length(trimspace(local.effective_custom_domain_name)) > 0 &&
        local.effective_certificate_arn != null &&
        length(trimspace(local.effective_certificate_arn)) > 0 :
        true
      ) &&
      (
        local.effective_api_authorizer_name != "" ?
        local.effective_api_authorizer_user_pool_arn != "" :
        true
      )
    )

    error_message = "Invalid api_gateway tier YAML values. Check stage, endpoint types, cache values, custom domain and authorizer settings."
  }
}
