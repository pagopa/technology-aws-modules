locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "event_mode",
    "cpu",
    "memory",
    "enable_execute_command",
    "cpu_high_scaling_adjustment",
    "container",
    "autoscaling",
    "event_autoscaling",
    "environment_variables",
  ])

  required_container_keys = toset([
    "cpu",
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

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))

  missing_container_keys = can(local.idvh_config.container) ? setsubtract(local.required_container_keys, toset(keys(local.idvh_config.container))) : local.required_container_keys

  missing_autoscaling_keys = can(local.idvh_config.autoscaling) ? setsubtract(local.required_autoscaling_keys, toset(keys(local.idvh_config.autoscaling))) : local.required_autoscaling_keys

  missing_event_autoscaling_keys = (
    can(local.idvh_config.event_autoscaling) && local.idvh_config.event_autoscaling != null
    ? setsubtract(local.required_event_autoscaling_keys, toset(keys(local.idvh_config.event_autoscaling)))
    : toset([])
  )
}

check "ecs_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_container_keys) == 0 &&
      length(local.missing_autoscaling_keys) == 0 &&
      length(local.missing_event_autoscaling_keys) == 0
    )

    error_message = "Invalid ecs tier YAML. Missing required keys in one or more ECS service blocks."
  }
}

check "ecs_yaml_types" {
  assert {
    condition = (
      can(tobool(local.idvh_config.event_mode)) &&
      can(tonumber(local.idvh_config.cpu)) &&
      can(tonumber(local.idvh_config.memory)) &&
      can(tobool(local.idvh_config.enable_execute_command)) &&
      can(tonumber(local.idvh_config.cpu_high_scaling_adjustment)) &&
      can(tonumber(local.idvh_config.container.cpu)) &&
      can(tonumber(local.idvh_config.container.container_port)) &&
      can(tonumber(local.idvh_config.container.host_port)) &&
      can(tonumber(local.idvh_config.container.logs_retention_days)) &&
      can(tobool(local.idvh_config.autoscaling.enable)) &&
      can(tonumber(local.idvh_config.autoscaling.desired_count)) &&
      can(tonumber(local.idvh_config.autoscaling.min_capacity)) &&
      can(tonumber(local.idvh_config.autoscaling.max_capacity)) &&
      (
        local.idvh_config.event_autoscaling == null ||
        (
          can(tonumber(local.idvh_config.event_autoscaling.desired_count)) &&
          can(tonumber(local.idvh_config.event_autoscaling.min_capacity)) &&
          can(tonumber(local.idvh_config.event_autoscaling.max_capacity))
        )
      ) &&
      can([for env_var in local.idvh_config.environment_variables : tostring(env_var.name)]) &&
      can([for env_var in local.idvh_config.environment_variables : tostring(env_var.value)])
    )

    error_message = "Invalid ecs tier YAML types. Check ECS service and autoscaling values."
  }
}

check "ecs_yaml_values" {
  assert {
    condition = (
      local.idvh_config.cpu > 0 &&
      local.idvh_config.memory > 0 &&
      local.idvh_config.container.cpu > 0 &&
      local.idvh_config.container.container_port > 0 &&
      local.idvh_config.container.container_port <= 65535 &&
      local.idvh_config.container.host_port > 0 &&
      local.idvh_config.container.host_port <= 65535 &&
      local.idvh_config.container.logs_retention_days > 0 &&
      local.idvh_config.autoscaling.min_capacity >= 0 &&
      local.idvh_config.autoscaling.max_capacity >= local.idvh_config.autoscaling.min_capacity &&
      local.idvh_config.autoscaling.desired_count >= local.idvh_config.autoscaling.min_capacity &&
      local.idvh_config.autoscaling.desired_count <= local.idvh_config.autoscaling.max_capacity &&
      (
        local.idvh_config.event_autoscaling != null ?
        local.idvh_config.event_autoscaling.min_capacity >= 0 &&
        local.idvh_config.event_autoscaling.max_capacity >= local.idvh_config.event_autoscaling.min_capacity &&
        local.idvh_config.event_autoscaling.desired_count >= local.idvh_config.event_autoscaling.min_capacity &&
        local.idvh_config.event_autoscaling.desired_count <= local.idvh_config.event_autoscaling.max_capacity :
        true
      ) &&
      (!local.effective_event_mode || local.idvh_config.event_autoscaling != null) &&
      alltrue([for env_var in local.idvh_config.environment_variables : length(trimspace(env_var.name)) > 0])
    )

    error_message = "Invalid ecs tier YAML values. Check service sizing, ports, autoscaling and environment variable names."
  }
}

check "ecs_dynamic_inputs" {
  assert {
    condition = (
      length(trimspace(var.service_name)) > 0 &&
      length(trimspace(var.container_name)) > 0 &&
      length(trimspace(var.image)) > 0 &&
      length(trimspace(var.cluster_arn)) > 0 &&
      length(trimspace(var.target_group_arn)) > 0 &&
      length(trimspace(var.nlb_security_group_id)) > 0 &&
      length(var.private_subnets) > 0 &&
      alltrue([for subnet in var.private_subnets : length(trimspace(subnet)) > 0])
    )

    error_message = "Invalid ECS dynamic inputs. Provide service/container names, image, cluster ARN, target group ARN, NLB security group ID and non-empty private subnets."
  }
}
