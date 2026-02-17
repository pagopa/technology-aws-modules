module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "lambda"
}

data "aws_caller_identity" "current" {}

locals {
  code_bucket_tier = try(local.idvh_config.code_bucket.idvh_resource_tier, null)
  requested_code_bucket_basename = join("-", compact([
    try(local.idvh_config.code_bucket.name_prefix, null),
    var.name,
    try(local.idvh_config.code_bucket.name_suffix, null),
  ]))

  attach_network_policy = length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0

  code_bucket_arn  = local.create_code_bucket ? module.code_bucket[0].arn : var.existing_code_bucket_arn
  code_bucket_name = local.create_code_bucket ? module.code_bucket[0].name : var.existing_code_bucket_name

  github_deploy_role_enabled = try(local.idvh_config.deploy_role.enabled, false) && var.github_repository != null
}

module "code_bucket" {
  count  = local.create_code_bucket ? 1 : 0
  source = "../s3_bucket"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = local.code_bucket_tier

  name = local.requested_code_bucket_basename
  tags = var.tags
}

module "lambda_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-lambda/releases
  # Pinned commit: https://github.com/terraform-aws-modules/terraform-aws-lambda/commit/55abacb6bfa49b3be9936c0947a913489aff0050
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=55abacb6bfa49b3be9936c0947a913489aff0050"

  function_name = var.name
  description   = var.description

  runtime       = local.idvh_config.runtime
  handler       = local.idvh_config.handler
  architectures = local.idvh_config.architectures

  create_package         = false
  local_existing_package = var.package_path

  ignore_source_code_hash = local.idvh_config.ignore_source_code_hash
  publish                 = local.idvh_config.publish

  memory_size = coalesce(var.memory_size, local.idvh_config.memory_size)
  timeout     = local.idvh_config.timeout

  environment_variables = var.environment_variables

  cloudwatch_logs_retention_in_days = local.idvh_config.cloudwatch_logs_retention_in_days

  attach_policy_json = var.lambda_policy_json != null
  policy_json        = var.lambda_policy_json

  attach_network_policy  = local.attach_network_policy
  vpc_subnet_ids         = local.attach_network_policy ? var.vpc_subnet_ids : []
  vpc_security_group_ids = local.attach_network_policy ? var.vpc_security_group_ids : []

  tags = var.tags
}

resource "aws_iam_role" "github_lambda_deploy" {
  count = local.github_deploy_role_enabled ? 1 : 0

  name        = "${var.name}-deploy-lambda"
  description = "Role to deploy Lambda functions with GitHub Actions"

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
            "token.actions.githubusercontent.com:sub" = ["repo:${var.github_repository}:*"]
          }
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:iss" = "https://token.actions.githubusercontent.com"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "deploy_lambda" {
  count = local.github_deploy_role_enabled ? 1 : 0

  name        = "${var.name}-deploy-lambda"
  description = "Policy to deploy Lambda and upload artifacts to code bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect   = "Allow"
          Action   = local.idvh_config.deploy_role.lambda_actions
          Resource = "*"
        },
      ],
      local.code_bucket_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:GetObject",
          ]
          Resource = [
            "${local.code_bucket_arn}/*",
          ]
        }
      ] : []
    )
  })
}

resource "aws_iam_role_policy_attachment" "deploy_lambda" {
  count = local.github_deploy_role_enabled ? 1 : 0

  role       = aws_iam_role.github_lambda_deploy[0].name
  policy_arn = aws_iam_policy.deploy_lambda[0].arn
}
