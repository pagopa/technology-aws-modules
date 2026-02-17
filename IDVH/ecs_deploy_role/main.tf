data "aws_caller_identity" "current" {}

locals {
  role_enabled = var.enabled && var.github_repository != null
}

resource "aws_iam_role" "deploy" {
  count = local.role_enabled ? 1 : 0

  name        = "${var.service_name}-deploy-ecs"
  description = var.role_description

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
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRPublish"
        Effect   = "Allow"
        Action   = var.ecr_actions
        Resource = ["*"]
      },
      {
        Sid      = "ECSTaskDefinition"
        Effect   = "Allow"
        Action   = var.ecs_actions
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
