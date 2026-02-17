# IDVH s3_bucket

Wrapper module for S3 that loads baseline settings from IDVH YAML catalog using:
- `product_name`
- `env`
- `idvh_resource_tier`

The module applies security defaults from the selected tier and keeps only dynamic deployment inputs as variables.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "artifact_bucket" {
  source = "git::https://github.com/your-org/your-terraform-modules.git//IDVH/s3_bucket?ref=main"

  product_name       = "example"
  env                = "dev"
  idvh_resource_tier = "standard"

  name = "artifacts"

  tags = {
    Project = "example"
  }
}
```
