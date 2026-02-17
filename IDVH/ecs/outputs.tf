output "service_name" {
  value = module.ecs_service.name
}

output "task_role_arn" {
  value = module.ecs_service.tasks_iam_role_arn
}

output "task_execution_role_arn" {
  value = module.ecs_service.task_exec_iam_role_arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.service.name
}
