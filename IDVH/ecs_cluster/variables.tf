variable "cluster_name" {
  type        = string
  description = "(Required) ECS cluster name"
}

variable "enable_container_insights" {
  type        = bool
  description = "(Required) Enable CloudWatch Container Insights for the cluster"
}

variable "fargate_capacity_providers" {
  type        = any
  description = "(Required) Fargate capacity provider configuration"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
