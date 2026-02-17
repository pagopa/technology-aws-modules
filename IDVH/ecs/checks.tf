locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "ecs_cluster_name",
    "event_mode",
    "enable_container_insights",
    "fargate_capacity_providers",
    "ecr_registers",
    "service_core",
    "internal_idp_enabled",
    "service_internal_idp",
    "nlb",
    "deploy_role",
  ])

  required_ecr_register_keys = toset([
    "name",
    "number_of_images_to_keep",
    "repository_image_tag_mutability",
  ])

  required_service_core_keys = toset([
    "service_name",
    "cpu",
    "memory",
    "enable_execute_command",
    "cpu_high_scaling_adjustment",
    "container",
    "autoscaling",
    "event_autoscaling",
    "environment_variables",
  ])

  required_service_internal_idp_keys = toset([
    "service_name",
    "cpu",
    "memory",
    "enable_execute_command",
    "container",
    "autoscaling",
    "environment_variables",
  ])

  required_service_container_keys = toset([
    "name",
    "cpu",
    "image_name",
    "container_port",
    "host_port",
    "logs_retention_days",
  ])

  required_autoscaling_keys = toset([
    "enable",
    "desired_count",
    "min_capacity",
    "max_capacity",
  ])

  required_event_autoscaling_keys = toset([
    "desired_count",
    "min_capacity",
    "max_capacity",
  ])

  required_nlb_keys = toset([
    "name",
    "internal",
    "cross_zone_enabled",
    "dns_record_client_routing_policy",
    "target_health_path",
    "deregistration_delay",
    "enable_deletion_protection",
  ])

  required_deploy_role_keys = toset([
    "enabled",
    "ecr_actions",
    "ecs_actions",
  ])

  required_capacity_provider_strategy_keys = toset([
    "weight",
    "base",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  missing_service_core_keys = can(local.idvh_config.service_core) ? setsubtract(local.required_service_core_keys, toset(keys(local.idvh_config.service_core))) : local.required_service_core_keys

  missing_service_internal_idp_keys = can(local.idvh_config.service_internal_idp) ? setsubtract(local.required_service_internal_idp_keys, toset(keys(local.idvh_config.service_internal_idp))) : local.required_service_internal_idp_keys

  missing_service_core_container_keys = can(local.idvh_config.service_core.container) ? setsubtract(local.required_service_container_keys, toset(keys(local.idvh_config.service_core.container))) : local.required_service_container_keys

  missing_service_internal_idp_container_keys = can(local.idvh_config.service_internal_idp.container) ? setsubtract(local.required_service_container_keys, toset(keys(local.idvh_config.service_internal_idp.container))) : local.required_service_container_keys

  missing_service_core_autoscaling_keys = can(local.idvh_config.service_core.autoscaling) ? setsubtract(local.required_autoscaling_keys, toset(keys(local.idvh_config.service_core.autoscaling))) : local.required_autoscaling_keys

  missing_service_internal_idp_autoscaling_keys = can(local.idvh_config.service_internal_idp.autoscaling) ? setsubtract(local.required_autoscaling_keys, toset(keys(local.idvh_config.service_internal_idp.autoscaling))) : local.required_autoscaling_keys

  missing_service_core_event_autoscaling_keys = (
    can(local.idvh_config.service_core.event_autoscaling) && local.idvh_config.service_core.event_autoscaling != null
    ? setsubtract(local.required_event_autoscaling_keys, toset(keys(local.idvh_config.service_core.event_autoscaling)))
    : toset([])
  )

  missing_nlb_keys = can(local.idvh_config.nlb) ? setsubtract(local.required_nlb_keys, toset(keys(local.idvh_config.nlb))) : local.required_nlb_keys

  missing_deploy_role_keys = can(local.idvh_config.deploy_role) ? setsubtract(local.required_deploy_role_keys, toset(keys(local.idvh_config.deploy_role))) : local.required_deploy_role_keys

  missing_ecr_register_keys = flatten([
    for register in try(local.idvh_config.ecr_registers, []) : [
      for key in local.required_ecr_register_keys : key if !can(register[key])
    ]
  ])

  missing_fargate_capacity_provider_keys = flatten([
    for _, provider in try(local.idvh_config.fargate_capacity_providers, {}) : [
      for key in local.required_capacity_provider_strategy_keys : key if !can(provider.default_capacity_provider_strategy[key])
    ]
  ])

  ecr_register_names = try([for register in local.idvh_config.ecr_registers : register.name], [])

  valid_ecr_mutability_values = toset([
    "IMMUTABLE",
    "MUTABLE",
  ])
}

check "ecs_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_service_core_keys) == 0 &&
      length(local.missing_service_internal_idp_keys) == 0 &&
      length(local.missing_service_core_container_keys) == 0 &&
      length(local.missing_service_internal_idp_container_keys) == 0 &&
      length(local.missing_service_core_autoscaling_keys) == 0 &&
      length(local.missing_service_internal_idp_autoscaling_keys) == 0 &&
      length(local.missing_service_core_event_autoscaling_keys) == 0 &&
      length(local.missing_nlb_keys) == 0 &&
      length(local.missing_deploy_role_keys) == 0 &&
      length(local.missing_ecr_register_keys) == 0 &&
      length(local.missing_fargate_capacity_provider_keys) == 0
    )

    error_message = "Invalid ecs tier YAML. Missing required keys in one or more ECS/ECR/NLB/deploy-role blocks."
  }
}

check "ecs_yaml_types" {
  assert {
    condition = (
      can(tostring(local.idvh_config.ecs_cluster_name)) &&
      can(tobool(local.idvh_config.event_mode)) &&
      can(tobool(local.idvh_config.enable_container_insights)) &&
      can([
        for _, provider in local.idvh_config.fargate_capacity_providers :
        tonumber(provider.default_capacity_provider_strategy.weight)
      ]) &&
      can([
        for _, provider in local.idvh_config.fargate_capacity_providers :
        tonumber(provider.default_capacity_provider_strategy.base)
      ]) &&
      can([for register in local.idvh_config.ecr_registers : tostring(register.name)]) &&
      can([for register in local.idvh_config.ecr_registers : tonumber(register.number_of_images_to_keep)]) &&
      can([for register in local.idvh_config.ecr_registers : tostring(register.repository_image_tag_mutability)]) &&
      can(tostring(local.idvh_config.service_core.service_name)) &&
      can(tonumber(local.idvh_config.service_core.cpu)) &&
      can(tonumber(local.idvh_config.service_core.memory)) &&
      can(tobool(local.idvh_config.service_core.enable_execute_command)) &&
      can(tonumber(local.idvh_config.service_core.cpu_high_scaling_adjustment)) &&
      can(tostring(local.idvh_config.service_core.container.name)) &&
      can(tonumber(local.idvh_config.service_core.container.cpu)) &&
      can(tostring(local.idvh_config.service_core.container.image_name)) &&
      can(tonumber(local.idvh_config.service_core.container.container_port)) &&
      can(tonumber(local.idvh_config.service_core.container.host_port)) &&
      can(tonumber(local.idvh_config.service_core.container.logs_retention_days)) &&
      can(tobool(local.idvh_config.service_core.autoscaling.enable)) &&
      can(tonumber(local.idvh_config.service_core.autoscaling.desired_count)) &&
      can(tonumber(local.idvh_config.service_core.autoscaling.min_capacity)) &&
      can(tonumber(local.idvh_config.service_core.autoscaling.max_capacity)) &&
      (
        local.idvh_config.service_core.event_autoscaling == null ||
        (
          can(tonumber(local.idvh_config.service_core.event_autoscaling.desired_count)) &&
          can(tonumber(local.idvh_config.service_core.event_autoscaling.min_capacity)) &&
          can(tonumber(local.idvh_config.service_core.event_autoscaling.max_capacity))
        )
      ) &&
      can([for env_var in local.idvh_config.service_core.environment_variables : tostring(env_var.name)]) &&
      can([for env_var in local.idvh_config.service_core.environment_variables : tostring(env_var.value)]) &&
      can(tobool(local.idvh_config.internal_idp_enabled)) &&
      can(tostring(local.idvh_config.service_internal_idp.service_name)) &&
      can(tonumber(local.idvh_config.service_internal_idp.cpu)) &&
      can(tonumber(local.idvh_config.service_internal_idp.memory)) &&
      can(tobool(local.idvh_config.service_internal_idp.enable_execute_command)) &&
      can(tostring(local.idvh_config.service_internal_idp.container.name)) &&
      can(tonumber(local.idvh_config.service_internal_idp.container.cpu)) &&
      can(tostring(local.idvh_config.service_internal_idp.container.image_name)) &&
      can(tonumber(local.idvh_config.service_internal_idp.container.container_port)) &&
      can(tonumber(local.idvh_config.service_internal_idp.container.host_port)) &&
      can(tonumber(local.idvh_config.service_internal_idp.container.logs_retention_days)) &&
      can(tobool(local.idvh_config.service_internal_idp.autoscaling.enable)) &&
      can(tonumber(local.idvh_config.service_internal_idp.autoscaling.desired_count)) &&
      can(tonumber(local.idvh_config.service_internal_idp.autoscaling.min_capacity)) &&
      can(tonumber(local.idvh_config.service_internal_idp.autoscaling.max_capacity)) &&
      can([for env_var in local.idvh_config.service_internal_idp.environment_variables : tostring(env_var.name)]) &&
      can([for env_var in local.idvh_config.service_internal_idp.environment_variables : tostring(env_var.value)]) &&
      can(tostring(local.idvh_config.nlb.name)) &&
      can(tobool(local.idvh_config.nlb.internal)) &&
      can(tobool(local.idvh_config.nlb.cross_zone_enabled)) &&
      can(tostring(local.idvh_config.nlb.dns_record_client_routing_policy)) &&
      can(tostring(local.idvh_config.nlb.target_health_path)) &&
      can(tonumber(local.idvh_config.nlb.deregistration_delay)) &&
      can(tobool(local.idvh_config.nlb.enable_deletion_protection)) &&
      can(tobool(local.idvh_config.deploy_role.enabled)) &&
      can([for action in local.idvh_config.deploy_role.ecr_actions : tostring(action)]) &&
      can([for action in local.idvh_config.deploy_role.ecs_actions : tostring(action)])
    )

    error_message = "Invalid ecs tier YAML types. Check ECS/ECR/service/autoscaling/NLB/deploy-role values."
  }
}

check "ecs_yaml_values" {
  assert {
    condition = (
      length(trimspace(local.effective_ecs_cluster_name)) > 0 &&
      length(trimspace(local.effective_nlb_name)) > 0 &&
      length(local.idvh_config.fargate_capacity_providers) > 0 &&
      alltrue([
        for provider_name, provider in local.idvh_config.fargate_capacity_providers :
        length(trimspace(provider_name)) > 0 &&
        provider.default_capacity_provider_strategy.weight >= 0 &&
        provider.default_capacity_provider_strategy.base >= 0
      ]) &&
      length(local.idvh_config.ecr_registers) > 0 &&
      alltrue([
        for register in local.idvh_config.ecr_registers :
        length(trimspace(register.name)) > 0 &&
        register.number_of_images_to_keep > 0 &&
        contains(local.valid_ecr_mutability_values, register.repository_image_tag_mutability)
      ]) &&
      length(distinct(local.ecr_register_names)) == length(local.ecr_register_names) &&
      length(trimspace(local.idvh_config.service_core.service_name)) > 0 &&
      local.idvh_config.service_core.cpu > 0 &&
      local.idvh_config.service_core.memory > 0 &&
      local.idvh_config.service_core.container.cpu > 0 &&
      length(trimspace(local.idvh_config.service_core.container.name)) > 0 &&
      contains(local.ecr_register_names, local.idvh_config.service_core.container.image_name) &&
      local.idvh_config.service_core.container.container_port > 0 &&
      local.idvh_config.service_core.container.container_port <= 65535 &&
      local.idvh_config.service_core.container.host_port > 0 &&
      local.idvh_config.service_core.container.host_port <= 65535 &&
      local.idvh_config.service_core.container.logs_retention_days > 0 &&
      local.idvh_config.service_core.autoscaling.min_capacity >= 0 &&
      local.idvh_config.service_core.autoscaling.max_capacity >= local.idvh_config.service_core.autoscaling.min_capacity &&
      local.idvh_config.service_core.autoscaling.desired_count >= local.idvh_config.service_core.autoscaling.min_capacity &&
      local.idvh_config.service_core.autoscaling.desired_count <= local.idvh_config.service_core.autoscaling.max_capacity &&
      (
        local.idvh_config.service_core.event_autoscaling != null ?
        local.idvh_config.service_core.event_autoscaling.min_capacity >= 0 &&
        local.idvh_config.service_core.event_autoscaling.max_capacity >= local.idvh_config.service_core.event_autoscaling.min_capacity &&
        local.idvh_config.service_core.event_autoscaling.desired_count >= local.idvh_config.service_core.event_autoscaling.min_capacity &&
        local.idvh_config.service_core.event_autoscaling.desired_count <= local.idvh_config.service_core.event_autoscaling.max_capacity :
        true
      ) &&
      (!local.effective_event_mode || local.idvh_config.service_core.event_autoscaling != null) &&
      alltrue([for env_var in local.idvh_config.service_core.environment_variables : length(trimspace(env_var.name)) > 0]) &&
      alltrue([for env_var in local.idvh_config.service_internal_idp.environment_variables : length(trimspace(env_var.name)) > 0]) &&
      length(trimspace(local.idvh_config.nlb.target_health_path)) > 0 &&
      startswith(local.idvh_config.nlb.target_health_path, "/") &&
      local.idvh_config.nlb.deregistration_delay >= 0 &&
      length(local.idvh_config.deploy_role.ecr_actions) > 0 &&
      length(local.idvh_config.deploy_role.ecs_actions) > 0 &&
      (
        local.effective_internal_idp_enabled ?
        length(trimspace(local.idvh_config.service_internal_idp.service_name)) > 0 &&
        local.idvh_config.service_internal_idp.cpu > 0 &&
        local.idvh_config.service_internal_idp.memory > 0 &&
        local.idvh_config.service_internal_idp.container.cpu > 0 &&
        length(trimspace(local.idvh_config.service_internal_idp.container.name)) > 0 &&
        contains(local.ecr_register_names, local.idvh_config.service_internal_idp.container.image_name) &&
        local.idvh_config.service_internal_idp.container.container_port > 0 &&
        local.idvh_config.service_internal_idp.container.container_port <= 65535 &&
        local.idvh_config.service_internal_idp.container.host_port > 0 &&
        local.idvh_config.service_internal_idp.container.host_port <= 65535 &&
        local.idvh_config.service_internal_idp.container.logs_retention_days > 0 &&
        local.idvh_config.service_internal_idp.autoscaling.min_capacity >= 0 &&
        local.idvh_config.service_internal_idp.autoscaling.max_capacity >= local.idvh_config.service_internal_idp.autoscaling.min_capacity &&
        local.idvh_config.service_internal_idp.autoscaling.desired_count >= local.idvh_config.service_internal_idp.autoscaling.min_capacity &&
        local.idvh_config.service_internal_idp.autoscaling.desired_count <= local.idvh_config.service_internal_idp.autoscaling.max_capacity :
        true
      )
    )

    error_message = "Invalid ecs tier YAML values. Check ECR names/mutability, ECS autoscaling, ports and NLB settings."
  }
}

check "ecs_dynamic_inputs" {
  assert {
    condition = (
      length(trimspace(var.vpc_id)) > 0 &&
      length(trimspace(var.vpc_cidr_block)) > 0 &&
      length(var.private_subnets) > 0 &&
      alltrue([for subnet in var.private_subnets : length(trimspace(subnet)) > 0]) &&
      length(trimspace(var.service_core_image_version)) > 0 &&
      (
        local.effective_internal_idp_enabled ?
        var.service_internal_idp_image_version != null && length(trimspace(var.service_internal_idp_image_version)) > 0 :
        true
      ) &&
      (var.github_repository != null ? can(regex("^[^/]+/[^/]+$", var.github_repository)) : true)
    )

    error_message = "Invalid ECS dynamic inputs. Provide VPC/subnets, a non-empty service_core_image_version, and service_internal_idp_image_version when internal IDP is enabled."
  }
}
