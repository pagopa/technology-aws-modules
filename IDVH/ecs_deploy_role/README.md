# IDVH ecs_deploy_role

Reusable wrapper module for GitHub OIDC deploy IAM role and policy for ECS services.

Structural defaults are loaded from the IDVH YAML tier using:
- `product_name`
- `env`
- `idvh_resource_tier`

Dynamic inputs stay explicit for service-specific values:
- `service_name`
- `github_repository`
- `pass_role_arns`

## Example

```hcl
module "ecs_deploy_role" {
	source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/ecs_deploy_role?ref=main"

	product_name       = "example"
	env                = "dev"
	idvh_resource_tier = "standard"

	service_name      = "example-dev-core"
	github_repository = "your-org/example"
	pass_role_arns = [
		"arn:aws:iam::123456789012:role/example-dev-core-task",
		"arn:aws:iam::123456789012:role/example-dev-core-task-exec",
	]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.63.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_idvh_loader"></a> [idvh\_loader](#module\_idvh\_loader) | ../01_idvh_loader | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for which the resource will be created | `string` | n/a | yes |
| <a name="input_idvh_resource_tier"></a> [idvh\_resource\_tier](#input\_idvh\_resource\_tier) | (Required) The IDVH resource tier key to be created | `string` | n/a | yes |
| <a name="input_pass_role_arns"></a> [pass\_role\_arns](#input\_pass\_role\_arns) | (Required) IAM role ARNs allowed in iam:PassRole | `list(string)` | n/a | yes |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | (Required) Product name used to identify the catalog to be used | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | (Required) Service name used as IAM role and policy prefix | `string` | n/a | yes |
| <a name="input_ecr_actions"></a> [ecr\_actions](#input\_ecr\_actions) | (Optional) Dynamic override for ECR deployment IAM actions. If null, values from IDVH tier YAML are used. | `list(string)` | `null` | no |
| <a name="input_ecs_actions"></a> [ecs\_actions](#input\_ecs\_actions) | (Optional) Dynamic override for ECS deployment IAM actions. If null, values from IDVH tier YAML are used. | `list(string)` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | (Optional) Dynamic override for deploy role creation. If null, enabled from IDVH tier YAML is used. | `bool` | `null` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | (Optional) GitHub repository in org/repo format | `string` | `null` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | (Optional) Dynamic override for the IAM policy description. If null, the value from IDVH tier YAML is used. | `string` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | (Optional) Dynamic override for the IAM role description. If null, the value from IDVH tier YAML is used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | n/a |
<!-- END_TF_DOCS -->