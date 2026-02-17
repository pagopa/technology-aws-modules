# IDVH api_gateway

Wrapper module for API Gateway HTTP API that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: protocol/stage/logging defaults are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "api_gateway" {
  source = "./IDVH/api_gateway"

  product_name       = "onemail"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "onemail-dev-http-api"

  tags = {
    Project = "onemail"
  }
}
```
