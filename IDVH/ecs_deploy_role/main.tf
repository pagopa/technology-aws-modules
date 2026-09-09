module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "ecs_deploy_role"
}

data "aws_caller_identity" "current" {}

locals {
  effective_enabled            = var.enabled != null ? var.enabled : local.idvh_config.enabled
  effective_ecr_actions        = var.ecr_actions != null ? var.ecr_actions : local.idvh_config.ecr_actions
  effective_ecs_actions        = var.ecs_actions != null ? var.ecs_actions : local.idvh_config.ecs_actions
  effective_role_description   = var.role_description != null ? var.role_description : local.idvh_config.role_description
  effective_policy_description = var.policy_description != null ? var.policy_description : local.idvh_config.policy_description

  role_enabled = local.effective_enabled && var.github_repository != null
}

resource "aws_iam_role" "deploy" {
  count = local.role_enabled ? 1 : 0

  name        = "${var.service_name}-deploy-ecs"
  description = local.effective_role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:iss" = "https://token.actions.githubusercontent.com"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.service_name}-deploy-ecs"
    }
  )
}

resource "aws_iam_policy" "deploy" {
  count = local.role_enabled ? 1 : 0

  name        = "${var.service_name}-deploy-ecs"
  description = local.effective_policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRPublish"
        Effect   = "Allow"
        Action   = local.effective_ecr_actions
        Resource = ["*"]
      },
      {
        Sid      = "ECSTaskDefinition"
        Effect   = "Allow"
        Action   = local.effective_ecs_actions
        Resource = "*"
      },
      {
        Sid      = "PassRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = var.pass_role_arns
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.service_name}-deploy-ecs"
    }
  )
}

resource "aws_iam_role_policy_attachment" "deploy" {
  count = local.role_enabled ? 1 : 0

  role       = aws_iam_role.deploy[0].name
  policy_arn = aws_iam_policy.deploy[0].arn
}
