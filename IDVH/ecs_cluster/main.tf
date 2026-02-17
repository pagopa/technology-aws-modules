module "cluster_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecs/releases/tag/v5.9.1
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecs/commit/45f532c06488d84f140af36241d164facb5e05f5
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=45f532c06488d84f140af36241d164facb5e05f5"

  cluster_name = var.cluster_name

  cluster_settings = [
    {
      name  = "containerInsights"
      value = var.enable_container_insights ? "enabled" : "disabled"
    },
  ]

  fargate_capacity_providers = var.fargate_capacity_providers

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}
