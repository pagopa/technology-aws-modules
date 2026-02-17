# IDVH dynamodb

Wrapper module for DynamoDB that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: billing/encryption/protection defaults are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "dynamodb" {
  source = "./IDVH/dynamodb"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  name     = "onemail-dev-table"
  hash_key = "pk"
  range_key = "sk"

  attributes = [
    {
      name = "pk"
      type = "S"
    },
    {
      name = "sk"
      type = "S"
    }
  ]

  tags = {
    Project = "onemail"
  }
}
```
