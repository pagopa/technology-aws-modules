# IDVH Standards Reference

## Architecture baseline
- Treat IDVH as a catalog-driven wrapper layer.
- Keep baseline and structural parameters in YAML tiers.
- Keep Terraform variables only for per-deployment dynamic inputs.
- Keep raw upstream modules pinned by commit hash or fixed version constraints.

## Loader baseline (`IDVH/01_idvh_loader`)
- Load catalog files from:
  - `IDVH/00_product_configs/common/<resource_type>.yml`
  - `IDVH/00_product_configs/<product>/common/<resource_type>.yml`
  - `IDVH/00_product_configs/<product>/<env>/<resource_type>.yml`
- Merge in this order: global common, product common, env specific.
- Validate `env` and resource type availability in variable validation blocks.

## Catalog baseline (`IDVH/00_product_configs`)
- Keep tiers explicit and environment-specific only where needed.
- Avoid empty string placeholders; omit optional keys when unused.
- Keep value types stable across environments for the same key.
- Keep optional nested objects present only when used.

## File-level responsibilities
- `main.tf`: compose effective values and wire resources.
- `checks.tf`: hold validation locals and `check` blocks.
- `variables.tf`: typed inputs with concise descriptions.
- `outputs.tf`: stable external contract.
- `versions.tf`: pinned minimum versions aligned across IDVH modules.

## Validation baseline
- Keep schema checks explicit with `required_*`, `missing_*`, and type/value assertions.
- Keep module behavior deterministic when tier keys are missing or malformed.
- Keep `terraform fmt` and `terraform validate` in the edit loop when provider access is available.
- Keep catalog scans for empty placeholders as part of validation.

## Terraform testing baseline
- Run `terraform test` for modules that already provide `.tftest.hcl` suites.
- Add or update `.tftest.hcl` tests when changing tier contracts, checks, or conditional wiring.
- Prefer mocked provider patterns for deterministic local tests when real cloud resources are not required.
- Keep tests focused on module contracts: required inputs, output values, and key conditional behaviors.
- Keep at least one negative-path assertion when introducing new validation checks.

## Documentation baseline
- Keep module `README.md` in sync with available tiers and example usage.
- Keep `LIBRARY.md` aligned with the catalog.
- Keep `resource_description.info` placeholders aligned with flattened YAML key names.

## Optional module references
- Load only the reference file that matches the target resource module when such files exist.
