# IDVH - Infrastructure Design Handbook for AWS

IDVH e un set di wrapper Terraform per AWS pensato per ridurre la configurazione manuale e standardizzare sicurezza e baseline operativa.

Ogni modulo carica la configurazione dal catalogo YAML usando la tripletta:
- `product_name`
- `env`
- `idh_resource_tier`

In questo modo l'utilizzatore imposta solo i parametri dinamici, mentre le impostazioni standard/sicurezza restano governate nel catalogo.

## Available modules

I moduli disponibili sono [elencati qui](./LIBRARY.md).

## How to add a new module

1. Crea una cartella modulo in `IDVH/<module_name>`
2. Aggiungi il catalogo YAML in `IDVH/00_product_configs` per product/env richiesti
3. Usa il loader nel modulo:

```hcl
module "idh_loader" {
  source = "../01_idvh_loader"

  product_name      = var.product_name
  env               = var.env
  idh_resource_tier = var.idh_resource_tier
  idh_resource_type = "<module_name>"
}
```

4. Leggi la configurazione con `module.idh_loader.idh_resource_configuration`
5. Aggiungi `resource_description.info` e `LIBRARY.md` per documentare i tier
