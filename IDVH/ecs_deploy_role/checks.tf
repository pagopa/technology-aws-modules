locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "enabled",
    "ecr_actions",
    "ecs_actions",
    "role_description",
    "policy_description",
  ])

  missing_tier_keys = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))
}

check "ecs_deploy_role_yaml_required_keys" {
  assert {
    condition = length(local.missing_tier_keys) == 0

    error_message = "Invalid ecs_deploy_role tier YAML. Missing required keys."
  }
}

check "ecs_deploy_role_yaml_types" {
  assert {
    condition = (
      can(tobool(local.idvh_config.enabled)) &&
      can([for action in local.idvh_config.ecr_actions : tostring(action)]) &&
      can([for action in local.idvh_config.ecs_actions : tostring(action)]) &&
      can(tostring(local.idvh_config.role_description)) &&
      can(tostring(local.idvh_config.policy_description))
    )

    error_message = "Invalid ecs_deploy_role tier YAML types. Check enabled, action lists and descriptions."
  }
}

check "ecs_deploy_role_yaml_values" {
  assert {
    condition = (
      alltrue([for action in local.idvh_config.ecr_actions : length(trimspace(action)) > 0]) &&
      alltrue([for action in local.idvh_config.ecs_actions : length(trimspace(action)) > 0]) &&
      length(trimspace(local.idvh_config.role_description)) > 0 &&
      length(trimspace(local.idvh_config.policy_description)) > 0
    )

    error_message = "Invalid ecs_deploy_role tier YAML values. Check action lists and descriptions."
  }
}

check "ecs_deploy_role_dynamic_inputs" {
  assert {
    condition = (
      length(trimspace(var.service_name)) > 0 &&
      (
        !local.role_enabled ||
        (
          length(trimspace(var.github_repository)) > 0 &&
          length(var.pass_role_arns) > 0 &&
          alltrue([for role_arn in var.pass_role_arns : length(trimspace(role_arn)) > 0])
        )
      )
    )

    error_message = "Invalid ecs_deploy_role dynamic inputs. Provide a non-empty service_name and, when the role is enabled, a GitHub repository and non-empty pass_role_arns."
  }
}