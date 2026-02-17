module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "api_gateway"
}

locals {
  effective_stage_name = var.stage_name != null ? var.stage_name : local.idvh_config.stage_name

  access_logs_enabled = try(local.idvh_config.access_logs.enabled, true)

  default_access_log_format = jsonencode({
    requestId      = "$context.requestId"
    sourceIp       = "$context.identity.sourceIp"
    requestTime    = "$context.requestTime"
    httpMethod     = "$context.httpMethod"
    routeKey       = "$context.routeKey"
    status         = "$context.status"
    protocol       = "$context.protocol"
    responseLength = "$context.responseLength"
  })

  effective_access_log_format = coalesce(
    var.access_log_format,
    try(local.idvh_config.access_logs.format, null),
    local.default_access_log_format,
  )

  access_log_group_name = "/aws/apigateway/${var.name}/${local.effective_stage_name}"
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = local.idvh_config.protocol_type
  description   = var.description

  disable_execute_api_endpoint = local.idvh_config.disable_execute_api_endpoint

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_cloudwatch_log_group" "api_access" {
  count = local.access_logs_enabled ? 1 : 0

  name              = local.access_log_group_name
  retention_in_days = local.idvh_config.access_logs.retention_in_days

  tags = merge(
    var.tags,
    {
      Name = local.access_log_group_name
    }
  )
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = local.effective_stage_name
  auto_deploy = local.idvh_config.auto_deploy

  dynamic "access_log_settings" {
    for_each = local.access_logs_enabled ? [1] : []

    content {
      destination_arn = aws_cloudwatch_log_group.api_access[0].arn
      format          = local.effective_access_log_format
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${local.effective_stage_name}"
    }
  )
}
