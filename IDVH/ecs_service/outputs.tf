output "name" {
  value = module.service_raw.name
}

output "tasks_iam_role_arn" {
  value = module.service_raw.tasks_iam_role_arn
}

output "task_exec_iam_role_arn" {
  value = module.service_raw.task_exec_iam_role_arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.service.name
}
