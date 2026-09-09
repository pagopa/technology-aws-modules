# IDVH ecs_cluster

Reusable wrapper module for ECS cluster creation with container insights and default capacity provider strategy.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_raw"></a> [cluster\_raw](#module\_cluster\_raw) | git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git | cfd967a4790b541b722ff94692588657b77d62ed |
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) ECS cluster name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | (Optional) Dynamic default capacity provider strategy override. If null, default\_capacity\_provider\_strategy from IDVH tier YAML is used. | `any` | `null` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | (Optional) Dynamic enable container insights override. If null, enable\_container\_insights from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
<!-- END_TF_DOCS -->