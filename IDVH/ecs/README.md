# IDVH ecs

Independent wrapper module for one ECS service.

This module does not create ECR repositories, ECS clusters, NLBs, or deploy roles.
It only creates and configures:
- one ECS service
- one CloudWatch log group
- optional task IAM policy

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
}
```
