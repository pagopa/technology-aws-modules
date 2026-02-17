# IDVH ecs

Wrapper module for ECS/ECR/NLB baseline that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: cluster/service topology, autoscaling defaults, ECR retention/mutability and deploy-role behavior are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "ecs" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/ecs?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  vpc_id = "vpc-0123456789abcdef0"
  private_subnets = [
    "subnet-0123456789abcdef0",
    "subnet-abcdef0123456789a",
  ]
  vpc_cidr_block = "10.0.0.0/16"

  service_core_image_version = "1.0.0"

  github_repository = "example-org/example-infra"
}
```
