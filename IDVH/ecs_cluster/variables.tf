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

variable "cluster_name" {
  type        = string
  description = "(Required) ECS cluster name"
}

variable "enable_container_insights" {
  type        = bool
  description = "(Optional) Dynamic enable container insights override. If null, enable_container_insights from IDVH tier YAML is used."
  default     = null
}

variable "default_capacity_provider_strategy" {
  type        = any
  description = "(Optional) Dynamic default capacity provider strategy override. If null, default_capacity_provider_strategy from IDVH tier YAML is used."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
