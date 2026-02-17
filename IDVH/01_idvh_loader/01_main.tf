locals {
  platform_env_tiers_configuration = try(yamldecode(file("${path.module}/../00_product_configs/${var.product_name}/${var.env}/${var.idvh_resource_type}.yml")), {})

  tiers_configurations = merge(
    local.platform_env_tiers_configuration
  )

  envs = ["dev", "uat", "prod"]
}
