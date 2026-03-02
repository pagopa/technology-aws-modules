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
  effective_fargate_capacity_providers = var.fargate_capacity_providers != null ? var.fargate_capacity_providers : local.idvh_config.fargate_capacity_providers
}

module "cluster_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v5.11.1
  # Module source: terraform-aws-modules/ecs/aws ~> 5.11.1
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=84cf54a603c9d976a150ec6aea4ab63eb0efd773"

  cluster_name = var.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = local.effective_enable_container_insights ? "enabled" : "disabled"
    },
  ]

  fargate_capacity_providers = local.effective_fargate_capacity_providers

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}
