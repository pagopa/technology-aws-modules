variable "name" {
  type        = string
  description = "(Required) NLB name"
}

variable "vpc_id" {
  type        = string
  description = "(Required) VPC identifier used by the NLB"
}

variable "private_subnets" {
  type        = list(string)
  description = "(Required) Private subnet IDs used by the NLB"
}

variable "vpc_cidr_block" {
  type        = string
  description = "(Required) CIDR block of the target VPC"
}

variable "core_container_port" {
  type        = number
  description = "(Required) Core service container port used by NLB listener and target group"
}

variable "internal" {
  type        = bool
  description = "(Required) Whether the NLB is internal"
}

variable "cross_zone_enabled" {
  type        = bool
  description = "(Required) Enable cross-zone load balancing"
}

variable "dns_record_client_routing_policy" {
  type        = string
  description = "(Required) DNS client routing policy"
}

variable "target_health_path" {
  type        = string
  description = "(Required) Target group health check path"
}

variable "deregistration_delay" {
  type        = number
  description = "(Required) Target group deregistration delay in seconds"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "(Required) Enable NLB deletion protection"
}

variable "target_group_name_prefix" {
  type        = string
  description = "(Optional) Prefix used for target group names"
  default     = "t1-"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
