# IDVH api_gateway

Wrapper module for API Gateway REST APIs that loads structural settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

IDVH rule: endpoint/stage/cache/method settings, usage plan and domain/authorizer defaults are defined by the selected YAML tier.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "api_gateway" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/api_gateway?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "example-dev-rest-api"
  body = file("./openapi.json")
}
```
