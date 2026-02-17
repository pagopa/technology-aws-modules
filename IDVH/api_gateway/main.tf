module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "api_gateway"
}

locals {
  effective_stage_name = var.stage_name != null ? var.stage_name : local.idvh_config.stage_name

  effective_endpoint_vpc_endpoint_ids = var.endpoint_vpc_endpoint_ids != null ? var.endpoint_vpc_endpoint_ids : local.idvh_config.endpoint_configuration.vpc_endpoint_ids

  effective_plan_api_key_name = var.plan_api_key_name != null ? var.plan_api_key_name : local.idvh_config.plan.api_key_name

  effective_custom_domain_name = var.custom_domain_name != null ? var.custom_domain_name : local.idvh_config.custom_domain.domain_name
  effective_certificate_arn    = var.certificate_arn != null ? var.certificate_arn : local.idvh_config.custom_domain.certificate_arn
  effective_api_mapping_key    = var.api_mapping_key != null ? var.api_mapping_key : local.idvh_config.custom_domain.api_mapping_key

  effective_create_custom_domain_name = (
    var.custom_domain_name != null ||
    var.certificate_arn != null ||
    local.idvh_config.custom_domain.create
  )

  effective_api_authorizer_name = var.api_authorizer_name != null ? var.api_authorizer_name : coalesce(local.idvh_config.api_authorizer.name, "")

  effective_api_authorizer_user_pool_arn = var.api_authorizer_user_pool_arn != null ? var.api_authorizer_user_pool_arn : coalesce(local.idvh_config.api_authorizer.user_pool_arn, "")
}

resource "aws_api_gateway_rest_api" "main" {
  name = var.name
  body = var.body

  endpoint_configuration {
    types            = local.idvh_config.endpoint_configuration.types
    vpc_endpoint_ids = local.effective_endpoint_vpc_endpoint_ids
  }

  disable_execute_api_endpoint = local.effective_create_custom_domain_name ? true : false

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main.*))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = local.effective_stage_name

  cache_cluster_enabled = local.idvh_config.api_cache_cluster_enabled
  cache_cluster_size    = local.idvh_config.api_cache_cluster_size

  xray_tracing_enabled = local.idvh_config.xray_tracing_enabled

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${local.effective_stage_name}"
    }
  )
}

resource "aws_api_gateway_usage_plan" "main" {
  name        = local.idvh_config.plan.name
  description = "Usage plan for ${var.name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  throttle_settings {
    burst_limit = local.idvh_config.plan.throttle_burst_limit
    rate_limit  = local.idvh_config.plan.throttle_rate_limit
  }

  tags = merge(
    var.tags,
    {
      Name = local.idvh_config.plan.name
    }
  )
}

resource "aws_api_gateway_api_key" "main" {
  count = local.effective_plan_api_key_name != null ? 1 : 0

  name = local.effective_plan_api_key_name

  tags = merge(
    var.tags,
    {
      Name = local.effective_plan_api_key_name
    }
  )
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = local.effective_plan_api_key_name != null ? 1 : 0

  key_id        = aws_api_gateway_api_key.main[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

resource "aws_iam_role" "apigw" {
  name = "${var.name}Role"

  assume_role_policy = <<EOF_ASSUME_ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF_ASSUME_ROLE

  tags = merge(
    var.tags,
    {
      Name = "${var.name}Role"
    }
  )
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.apigw.id

  policy = <<EOF_CLOUDWATCH_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF_CLOUDWATCH_POLICY
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${local.effective_stage_name}"
  retention_in_days = local.idvh_config.cloudwatch_logs_retention_in_days

  tags = merge(
    var.tags,
    {
      Name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/${local.effective_stage_name}"
    }
  )
}

resource "aws_api_gateway_method_settings" "main" {
  for_each = {
    for method_setting in local.idvh_config.method_settings :
    method_setting.method_path => method_setting
  }

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name

  method_path = each.value.method_path

  settings {
    metrics_enabled                         = try(each.value.metrics_enabled, false)
    logging_level                           = try(each.value.logging_level, "OFF")
    data_trace_enabled                      = try(each.value.data_trace_enabled, false)
    throttling_rate_limit                   = try(each.value.throttling_rate_limit, -1)
    throttling_burst_limit                  = try(each.value.throttling_burst_limit, -1)
    caching_enabled                         = try(each.value.caching_enabled, false)
    cache_ttl_in_seconds                    = try(each.value.cache_ttl_in_seconds, 0)
    cache_data_encrypted                    = try(each.value.cache_data_encrypted, false)
    require_authorization_for_cache_control = try(each.value.require_authorization_for_cache_control, false)
  }
}

resource "aws_api_gateway_domain_name" "main" {
  count = local.effective_create_custom_domain_name ? 1 : 0

  domain_name              = local.effective_custom_domain_name
  regional_certificate_arn = local.effective_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name = local.effective_custom_domain_name
    }
  )
}

resource "aws_apigatewayv2_api_mapping" "main" {
  count = local.effective_custom_domain_name != null ? 1 : 0

  api_id      = aws_api_gateway_rest_api.main.id
  stage       = local.effective_stage_name
  domain_name = local.effective_custom_domain_name

  api_mapping_key = local.effective_api_mapping_key
}

resource "aws_api_gateway_authorizer" "main" {
  count = local.effective_api_authorizer_name != "" ? 1 : 0

  name          = local.effective_api_authorizer_name
  rest_api_id   = aws_api_gateway_rest_api.main.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [local.effective_api_authorizer_user_pool_arn]
}
