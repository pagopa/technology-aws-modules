variable "product_name" {
  type        = string
  description = "(Required) Product name used to identify the catalog to be used"

  validation {
    condition     = length(var.product_name) <= 12
    error_message = "Max length is 12 chars."
  }
}

variable "env" {
  type        = string
  description = "(Required) Environment for which the resource will be created"
}

variable "idvh_resource_tier" {
  type        = string
  description = "(Required) The IDVH resource tier key to be created"
}

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
  description = "(Optional) Dynamic core container port override. If null, core_container_port from IDVH tier YAML is used."
  default     = null
}

variable "internal" {
  type        = bool
  description = "(Optional) Dynamic internal override. If null, internal from IDVH tier YAML is used."
  default     = null
}

variable "cross_zone_enabled" {
  type        = bool
  description = "(Optional) Dynamic cross-zone override. If null, cross_zone_enabled from IDVH tier YAML is used."
  default     = null
}

variable "dns_record_client_routing_policy" {
  type        = string
  description = "(Optional) Dynamic DNS routing policy override. If null, dns_record_client_routing_policy from IDVH tier YAML is used."
  default     = null
}

variable "target_health_path" {
  type        = string
  description = "(Optional) Dynamic target health path override. If null, target_health_path from IDVH tier YAML is used."
  default     = null
}

variable "deregistration_delay" {
  type        = number
  description = "(Optional) Dynamic deregistration delay override. If null, deregistration_delay from IDVH tier YAML is used."
  default     = null
}

variable "enable_deletion_protection" {
  type        = bool
  description = "(Optional) Dynamic deletion protection override. If null, enable_deletion_protection from IDVH tier YAML is used."
  default     = null
}

variable "target_group_name_prefix" {
  type        = string
  description = "(Optional) Dynamic prefix override for target group names. If null, target_group_name_prefix from IDVH tier YAML is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
