output "lambda_function_name" {
  value = module.lambda_raw.lambda_function_name
}

output "lambda_function_arn" {
  value = module.lambda_raw.lambda_function_arn
}

output "lambda_log_group_name" {
  value = module.lambda_raw.lambda_cloudwatch_log_group_name
}

output "github_lambda_deploy_role_arn" {
  value = null
}

output "github_lambda_deploy_policy_arn" {
  value = null
}
