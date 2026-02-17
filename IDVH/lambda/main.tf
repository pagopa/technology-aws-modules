module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "lambda"
}

data "aws_caller_identity" "current" {}

locals {
  idvh_config = module.idvh_loader.idvh_resource_configuration

  required_tier_keys = toset([
    "runtime",
    "handler",
    "architectures",
    "memory_size",
    "timeout",
    "publish",
    "ignore_source_code_hash",
    "cloudwatch_logs_retention_in_days",
    "code_bucket",
    "deploy_role",
  ])
  required_code_bucket_keys = toset([
    "enabled",
    "idvh_resource_tier",
    "name_suffix",
  ])
  required_deploy_role_keys = toset([
    "enabled",
    "lambda_actions",
  ])

  missing_tier_keys        = setsubtract(local.required_tier_keys, toset(keys(local.idvh_config)))
  missing_code_bucket_keys = can(local.idvh_config.code_bucket) ? setsubtract(local.required_code_bucket_keys, toset(keys(local.idvh_config.code_bucket))) : local.required_code_bucket_keys
  missing_deploy_role_keys = can(local.idvh_config.deploy_role) ? setsubtract(local.required_deploy_role_keys, toset(keys(local.idvh_config.deploy_role))) : local.required_deploy_role_keys

  effective_runtime       = tostring(local.idvh_config.runtime)
  effective_handler       = tostring(local.idvh_config.handler)
  effective_architectures = [for a in local.idvh_config.architectures : tostring(a)]
  effective_memory_size   = coalesce(var.memory_size, tonumber(local.idvh_config.memory_size))
  effective_timeout       = tonumber(local.idvh_config.timeout)
  effective_publish       = tobool(local.idvh_config.publish)

  effective_create_code_bucket      = tobool(local.idvh_config.code_bucket.enabled)
  effective_code_bucket_tier        = tostring(local.idvh_config.code_bucket.idvh_resource_tier)
  effective_code_bucket_name_prefix = try(tostring(local.idvh_config.code_bucket.name_prefix), null)
  effective_code_bucket_name_suffix = tostring(local.idvh_config.code_bucket.name_suffix)
  requested_code_bucket_basename = join("-", compact([
    local.effective_code_bucket_name_prefix,
    var.name,
    local.effective_code_bucket_name_suffix,
  ]))

  attach_network_policy = length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0

  effective_code_bucket_arn  = local.effective_create_code_bucket ? module.code_bucket[0].arn : var.existing_code_bucket_arn
  effective_code_bucket_name = local.effective_create_code_bucket ? module.code_bucket[0].name : var.existing_code_bucket_name

  effective_create_github_deploy_role = tobool(local.idvh_config.deploy_role.enabled)
  github_deploy_role_enabled          = local.effective_create_github_deploy_role && var.github_repository != null

  deploy_lambda_actions = [for action in local.idvh_config.deploy_role.lambda_actions : tostring(action)]
}

module "code_bucket" {
  count  = local.effective_create_code_bucket ? 1 : 0
  source = "../s3_bucket"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = local.effective_code_bucket_tier

  name = local.requested_code_bucket_basename
  tags = var.tags
}

module "lambda_raw" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=55abacb6bfa49b3be9936c0947a913489aff0050"

  function_name = var.name
  description   = var.description

  runtime       = local.effective_runtime
  handler       = local.effective_handler
  architectures = local.effective_architectures

  create_package         = false
  local_existing_package = var.package_path

  ignore_source_code_hash = tobool(local.idvh_config.ignore_source_code_hash)
  publish                 = local.effective_publish

  memory_size = local.effective_memory_size
  timeout     = local.effective_timeout

  environment_variables = var.environment_variables

  cloudwatch_logs_retention_in_days = tonumber(local.idvh_config.cloudwatch_logs_retention_in_days)

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
          Action   = local.deploy_lambda_actions
          Resource = "*"
        },
      ],
      local.effective_code_bucket_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:GetObject",
          ]
          Resource = [
            "${local.effective_code_bucket_arn}/*",
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
