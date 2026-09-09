# IDVH nlb

Reusable wrapper module for an ECS-facing Network Load Balancer with optional internal IDP listener and target group.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |
| <a name="module_nlb_raw"></a> [nlb\_raw](#module\_nlb\_raw) | git::https://github.com/terraform-aws-modules/terraform-aws-alb.git | eb15097ece19399858ae84518bb900bd34494a74 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) NLB name | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | (Required) Private subnet IDs used by the NLB | `list(string)` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | (Required) CIDR block of the target VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) VPC identifier used by the NLB | `string` | n/a | yes |
| <a name="input_core_container_port"></a> [core\_container\_port](#input\_core\_container\_port) | (Optional) Dynamic core container port override. If null, core\_container\_port from IDVH tier YAML is used. | `number` | `null` | no |
| <a name="input_cross_zone_enabled"></a> [cross\_zone\_enabled](#input\_cross\_zone\_enabled) | (Optional) Dynamic cross-zone override. If null, cross\_zone\_enabled from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (Optional) Dynamic deregistration delay override. If null, deregistration\_delay from IDVH tier YAML is used. | `number` | `null` | no |
| <a name="input_dns_record_client_routing_policy"></a> [dns\_record\_client\_routing\_policy](#input\_dns\_record\_client\_routing\_policy) | (Optional) Dynamic DNS routing policy override. If null, dns\_record\_client\_routing\_policy from IDVH tier YAML is used. | `string` | `null` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | (Optional) Dynamic deletion protection override. If null, enable\_deletion\_protection from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | (Optional) Dynamic internal override. If null, internal from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_group_name_prefix"></a> [target\_group\_name\_prefix](#input\_target\_group\_name\_prefix) | (Optional) Dynamic prefix override for target group names. If null, target\_group\_name\_prefix from IDVH tier YAML is used. | `string` | `null` | no |
| <a name="input_target_health_path"></a> [target\_health\_path](#input\_target\_health\_path) | (Optional) Dynamic target health path override. If null, target\_health\_path from IDVH tier YAML is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_target_groups"></a> [target\_groups](#output\_target\_groups) | n/a |
<!-- END_TF_DOCS -->