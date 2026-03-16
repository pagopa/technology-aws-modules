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
