output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  value = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.this.execution_arn
}

output "stage_id" {
  value = aws_apigatewayv2_stage.this.id
}

output "stage_name" {
  value = aws_apigatewayv2_stage.this.name
}

output "stage_invoke_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}

output "access_log_group_name" {
  value = try(aws_cloudwatch_log_group.api_access[0].name, null)
}
