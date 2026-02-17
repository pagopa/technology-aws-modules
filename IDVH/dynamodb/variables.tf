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

variable "idp_entity_ids" {
  type        = list(string)
  description = "(Optional) IDP entity IDs used to seed IDP status history default items"
  default     = null
}

variable "clients" {
  type = list(object({
    client_id     = string
    friendly_name = string
  }))
  description = "(Optional) Clients used to seed client status history default items"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to apply to resources"
  default     = {}
}
