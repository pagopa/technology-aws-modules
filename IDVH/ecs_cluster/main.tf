module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "ecs_cluster"
}

locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  effective_enable_container_insights = var.enable_container_insights != null ? var.enable_container_insights : local.idvh_config.enable_container_insights
  effective_default_capacity_provider_strategy = var.default_capacity_provider_strategy != null ? var.default_capacity_provider_strategy : local.idvh_config.default_capacity_provider_strategy
}

module "cluster_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v6.0.0
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/cfd967a4790b541b722ff94692588657b77d62ed
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=cfd967a4790b541b722ff94692588657b77d62ed"

  cluster_name = var.cluster_name

  cluster_setting = [
    {
      name  = "containerInsights"
      value = local.effective_enable_container_insights ? "enabled" : "disabled"
    },
  ]

  default_capacity_provider_strategy = local.effective_default_capacity_provider_strategy

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}
