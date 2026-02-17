# IDVH s3_bucket

Wrapper module per S3 che carica configurazioni dinamiche da catalogo YAML usando:
- `product_name`
- `env`
- `idvh_resource_tier`

Il modulo applica default di sicurezza dal catalogo e lascia variabili solo per parametri dinamici.

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "artifact_bucket" {
  source = "./IDVH/s3_bucket"

  product_name      = "onemail"
  env               = "dev"
  idvh_resource_tier = "standard"

  name = "artifacts"

  tags = {
    Project = "onemail"
  }
}
```
