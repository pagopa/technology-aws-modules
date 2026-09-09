module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "ecr"
}

locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  effective_repositories = var.repositories != null ? var.repositories : local.idvh_config.repositories

  repositories_by_key = {
    for repository_key, repository in local.effective_repositories :
    repository_key => merge(
      repository,
      {
        name = coalesce(
          try(var.repository_name_overrides[repository_key], null),
          "${var.repository_name_prefix}-${replace(repository_key, "_", "-")}"
        )
      }
    )
  }
}

module "repository" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-ecr/releases/tag/v1.6.0
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-ecr/commit/9f4b587846551110b0db199ea5599f016570fefe
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git?ref=9f4b587846551110b0db199ea5599f016570fefe"

  for_each = local.repositories_by_key

  repository_name                   = each.value.name
  repository_read_write_access_arns = []
  repository_image_tag_mutability   = each.value.repository_image_tag_mutability

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.number_of_images_to_keep} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.number_of_images_to_keep
        }
        action = {
          type = "expire"
        }
      },
    ]
  })

  create_registry_replication_configuration = false
  registry_replication_rules                = []

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}
