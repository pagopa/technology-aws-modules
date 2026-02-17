output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

output "core_service_name" {
  value = module.ecs_core_service.name
}

output "core_task_role_arn" {
  value = module.ecs_core_service.tasks_iam_role_arn
}

output "core_task_execution_role_arn" {
  value = module.ecs_core_service.task_exec_iam_role_arn
}

output "internal_idp_service_name" {
  value = try(module.ecs_internal_idp_service[0].name, null)
}

output "internal_idp_task_role_arn" {
  value = try(module.ecs_internal_idp_service[0].tasks_iam_role_arn, null)
}

output "internal_idp_task_execution_role_arn" {
  value = try(module.ecs_internal_idp_service[0].task_exec_iam_role_arn, null)
}

output "ecr_repository_urls" {
  value = {
    for repository_name, repository in module.ecr :
    repository_name => repository.repository_url
  }
}

output "nlb_arn" {
  value = module.elb.arn
}

output "nlb_dns_name" {
  value = module.elb.dns_name
}

output "ecs_core_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_core.name
}

output "ecs_internal_idp_log_group_name" {
  value = try(aws_cloudwatch_log_group.ecs_internal_idp[0].name, null)
}

output "ecs_deploy_iam_role_arn" {
  value = try(aws_iam_role.githubecsdeploy[0].arn, null)
}

output "ecs_deploy_internal_idp_iam_role_arn" {
  value = try(aws_iam_role.githubecsdeploy_internal_idp[0].arn, null)
}
