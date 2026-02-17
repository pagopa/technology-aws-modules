# IDVH lambda

Wrapper module per AWS Lambda che carica configurazioni dinamiche da catalogo YAML usando:
- `product_name`
- `env`
- `idvh_resource_tier`

Regola IDVH: parametri strutturali (es. `runtime`, `handler`, `architectures`, `timeout`, `publish`, retention log, creazione code bucket) sono definiti nel tier YAML.  
Parametro dinamico principale lasciato come variabile: `memory_size`.

Il modulo usa:
- raw module Lambda `terraform-aws-modules` pinned by commit hash
- modulo IDVH `s3_bucket` con `source = "../s3_bucket"` per il code bucket

## IDVH resources available
[Here's](./LIBRARY.md) the list of `idvh_resource_tier` available for this module.

## Example

```hcl
module "notifications_lambda" {
  source = "./IDVH/lambda"

  product_name      = "onemail"
  env               = "dev"
  idvh_resource_tier = "standard"

  name         = "onemail-dev-notifications"
  package_path = "./artifacts/notifications.zip"

  environment_variables = {
    STAGE = "dev"
  }

  github_repository = "my-org/my-repo"

  tags = {
    Project = "onemail"
  }
}
```

## Tier disponibili

- `standard`: crea automaticamente il code bucket IDVH
- `standard_external_code_bucket`: non crea il bucket; richiede `existing_code_bucket_name` e `existing_code_bucket_arn`
