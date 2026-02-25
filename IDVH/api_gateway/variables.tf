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
  description = "(Required) REST API name"
}

variable "body" {
  type        = string
  description = "(Required) OpenAPI/Swagger specification body"
}

variable "stage_name" {
  type        = string
  description = "(Optional) Dynamic stage name override. If null, stage_name from IDVH tier YAML is used."
  default     = null
}

variable "endpoint_vpc_endpoint_ids" {
  type        = list(string)
  description = "(Optional) Dynamic VPC endpoint IDs override for PRIVATE endpoint configurations"
  default     = null
}

variable "endpoint_api_types" {
  type        = list(string)
  description = "(Optional) Dynamic API types override for endpoint configuration"
  default     = null
}

variable "plan_api_key_name" {
  type        = string
  description = "(Optional) Dynamic usage-plan API key name override"
  default     = null
}

variable "custom_domain_name" {
  type        = string
  description = "(Optional) Dynamic custom domain override"
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "(Optional) Dynamic certificate ARN override for custom domain"
  default     = null
}

variable "api_mapping_key" {
  type        = string
  description = "(Optional) Dynamic API mapping key override"
  default     = null
}

variable "api_authorizer_name" {
  type        = string
  description = "(Optional) Dynamic Cognito authorizer name override"
  default     = null
}

variable "api_authorizer_user_pool_arn" {
  type        = string
  description = "(Optional) Dynamic Cognito user pool ARN override"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
