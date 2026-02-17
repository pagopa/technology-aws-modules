# IDVH sqs

Wrapper module for AWS SQS that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: queue behavior (retention, delays, encryption defaults, DLQ policy) is defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "sqs" {
  source = "./IDVH/sqs"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "onemail-dev-events"

  tags = {
    Project = "onemail"
  }
}
```
