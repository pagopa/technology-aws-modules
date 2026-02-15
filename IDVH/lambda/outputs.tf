output "lambda_function_name" {
  value = module.lambda_raw.lambda_function_name
}

output "lambda_function_arn" {
  value = module.lambda_raw.lambda_function_arn
}

output "lambda_log_group_name" {
  value = module.lambda_raw.lambda_cloudwatch_log_group_name
}

output "code_bucket_name" {
  value = local.effective_code_bucket_name
}

output "code_bucket_arn" {
  value = local.effective_code_bucket_arn
}

output "github_lambda_deploy_role_arn" {
  value = try(aws_iam_role.github_lambda_deploy[0].arn, null)
}

output "github_lambda_deploy_policy_arn" {
  value = try(aws_iam_policy.deploy_lambda[0].arn, null)
}
