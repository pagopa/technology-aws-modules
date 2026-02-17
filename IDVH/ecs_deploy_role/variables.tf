variable "enabled" {
  type        = bool
  description = "(Required) Enable deploy role creation"
}

variable "service_name" {
  type        = string
  description = "(Required) Service name used as IAM role and policy prefix"
}

variable "github_repository" {
  type        = string
  description = "(Optional) GitHub repository in org/repo format"
  default     = null
}

variable "ecr_actions" {
  type        = list(string)
  description = "(Required) IAM actions for ECR deployment operations"
}

variable "ecs_actions" {
  type        = list(string)
  description = "(Required) IAM actions for ECS deployment operations"
}

variable "pass_role_arns" {
  type        = list(string)
  description = "(Required) IAM role ARNs allowed in iam:PassRole"
}

variable "role_description" {
  type        = string
  description = "(Optional) IAM role description"
  default     = "Role to deploy ECS service with GitHub Actions."
}

variable "policy_description" {
  type        = string
  description = "(Optional) IAM policy description"
  default     = "Policy to allow GitHub Actions deployments on ECS service."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to IAM resources"
  default     = {}
}
