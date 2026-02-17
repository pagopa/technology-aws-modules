# IDVH dynamodb

Wrapper module for the OneIdentity DynamoDB stack that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: table protection/stream/PITR/KMS defaults are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "dynamodb" {
  source = "./IDVH/dynamodb"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  idp_entity_ids = ["https://idp.example.com/metadata"]

  clients = [
    {
      client_id     = "client-app"
      friendly_name = "Client App"
    }
  ]
}
```
