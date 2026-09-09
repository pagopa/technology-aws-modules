# IDVH ecs

Independent wrapper module for one ECS service.

This module does not create ECR repositories, ECS clusters, or NLBs.
It creates and configures:
- one ECS service
- one CloudWatch log group
- optional task IAM policy
- optional sibling deploy role through `IDVH/ecs_deploy_role`

Structural defaults are loaded from the IDVH YAML tier using:
- `product_name`
- `env`
- `idvh_resource_tier`

You compose this module with other sibling modules at a higher level.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "ecs" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/ecs?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  service_name       = "example-dev-core"
  container_name     = "core"
  image              = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/example-dev-core:1.0.0"
  cluster_arn        = "arn:aws:ecs:eu-west-1:123456789012:cluster/example-dev-ecs-cluster"
  private_subnets    = ["subnet-0123456789abcdef0"]
  target_group_arn   = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/example/1234567890abcdef"
  nlb_security_group_id = "sg-0123456789abcdef0"

  create_deploy_role           = true
  deploy_role_github_repository = "your-org/example"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_deploy_role"></a> [ecs\_deploy\_role](#module\_ecs\_deploy\_role) | ../ecs_deploy_role | n/a |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service | 1553f58d5c9d71afd1b87ebf99ab8d150108e1d5 |
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | (Required) ECS cluster ARN hosting the service | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | (Required) Main container name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | (Required) Full container image URI including tag | `string` | n/a | yes |
| <a name="input_nlb_security_group_id"></a> [nlb\_security\_group\_id](#input\_nlb\_security\_group\_id) | (Required) NLB security group ID used for ECS ingress rules | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | (Required) Private subnet IDs used by the ECS service | `list(string)` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | (Required) ECS service name | `string` | n/a | yes |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | (Required) NLB target group ARN attached to the ECS service | `string` | n/a | yes |
| <a name="input_create_deploy_role"></a> [create\_deploy\_role](#input\_create\_deploy\_role) | (Optional) When true, also creates the sibling ecs\_deploy\_role module using the same IDVH tier. | `bool` | `false` | no |
| <a name="input_deploy_role_additional_pass_role_arns"></a> [deploy\_role\_additional\_pass\_role\_arns](#input\_deploy\_role\_additional\_pass\_role\_arns) | (Optional) Additional IAM role ARNs appended to the pass\_role\_arns automatically derived for the optional ecs\_deploy\_role module. | `list(string)` | `[]` | no |
| <a name="input_deploy_role_github_repository"></a> [deploy\_role\_github\_repository](#input\_deploy\_role\_github\_repository) | (Optional) GitHub repository in org/repo format used by the optional ecs\_deploy\_role module. | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | (Optional) Additional environment variables appended to tier defaults | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_event_mode"></a> [event\_mode](#input\_event\_mode) | (Optional) Dynamic event-mode override. If null, event\_mode from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_task_policy_json"></a> [task\_policy\_json](#input\_task\_policy\_json) | (Optional) IAM policy JSON attached to the ECS task role | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_role_arn"></a> [deploy\_role\_arn](#output\_deploy\_role\_arn) | n/a |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | n/a |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | n/a |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | n/a |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | n/a |
<!-- END_TF_DOCS -->