variable "service_name" {
  type        = string
  description = "(Required) ECS service name"
}

variable "cluster_arn" {
  type        = string
  description = "(Required) ECS cluster ARN"
}

variable "cpu" {
  type        = number
  description = "(Required) ECS task CPU"
}

variable "memory" {
  type        = number
  description = "(Required) ECS task memory"
}

variable "enable_execute_command" {
  type        = bool
  description = "(Required) Enable ECS execute command"
}

variable "container_name" {
  type        = string
  description = "(Required) Main container name"
}

variable "container_cpu" {
  type        = number
  description = "(Required) Container CPU"
}

variable "container_port" {
  type        = number
  description = "(Required) Container port"
}

variable "host_port" {
  type        = number
  description = "(Required) Host port"
}

variable "image" {
  type        = string
  description = "(Required) Full container image URI including tag"
}

variable "logs_retention_days" {
  type        = number
  description = "(Required) CloudWatch log retention in days"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Optional) Container environment variables"
  default     = []
}

variable "autoscaling" {
  type = object({
    enable        = bool
    desired_count = number
    min_capacity  = number
    max_capacity  = number
  })
  description = "(Required) Service autoscaling configuration"
}

variable "autoscaling_policies" {
  type        = map(any)
  description = "(Optional) Additional autoscaling policies"
  default     = {}
}

variable "private_subnets" {
  type        = list(string)
  description = "(Required) Private subnet IDs used by the ECS service"
}

variable "target_group_arn" {
  type        = string
  description = "(Required) NLB target group ARN attached to the ECS service"
}

variable "nlb_security_group_id" {
  type        = string
  description = "(Required) NLB security group ID used for ECS ingress rules"
}

variable "task_policy_json" {
  type        = string
  description = "(Optional) IAM policy JSON attached to the ECS task role"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
