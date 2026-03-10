module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "lambda"
}

locals {
  attach_network_policy = length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0
}

module "lambda_raw" {
  # Release URL: https://github.com/terraform-aws-modules/terraform-aws-lambda/releases/tag/v8.5.0
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

  memory_size                    = coalesce(var.memory_size, local.idvh_config.memory_size)
  timeout                        = local.idvh_config.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment_variables = var.environment_variables

  cloudwatch_logs_retention_in_days = local.idvh_config.cloudwatch_logs_retention_in_days

  attach_policy_json = var.lambda_policy_json != null
  policy_json        = var.lambda_policy_json

  attach_network_policy  = local.attach_network_policy
  vpc_subnet_ids         = local.attach_network_policy ? var.vpc_subnet_ids : []
  vpc_security_group_ids = local.attach_network_policy ? var.vpc_security_group_ids : []

  tags = var.tags
}
