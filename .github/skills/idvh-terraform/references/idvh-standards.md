# IDVH Standards Reference

## Architecture baseline
- Treat IDVH as a catalog-driven wrapper layer.
- Keep baseline and structural parameters in YAML tiers.
- Keep Terraform variables only for per-deployment dynamic inputs.
- Keep modules independently consumable and single-responsibility by default.
- Prefer decomposition through sibling modules under `IDVH/` over nested submodules.
- Keep module boundaries pragmatic: aim for lean modules, but avoid splitting to the point of orchestration overhead.
- Keep raw upstream modules pinned by commit hash.
- For upstream Terraform modules, use GitHub sources under `https://github.com/terraform-aws-modules`.
- Add a release URL comment above each pinned module source, pointing to a numeric tag (`.../releases/tag/vX.Y.Z`).

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
- Keep catalog data focused on reusable settings; avoid project-specific names/identifiers in structural keys.

## File-level responsibilities
- `main.tf`: compose effective values and wire resources.
- `checks.tf`: hold validation locals and `check` blocks.
- `variables.tf`: typed inputs with concise descriptions.
- `outputs.tf`: stable external contract.
- `versions.tf`: pinned minimum versions aligned across IDVH modules.
- Prefer string interpolation over `format()` unless `format()` is required for clarity.

## Validation baseline
- Keep schema checks explicit with `required_*`, `missing_*`, and type/value assertions.
- Keep module behavior deterministic when tier keys are missing or malformed.
- Keep `terraform fmt` and `terraform validate` in the edit loop when provider access is available.
- Keep catalog scans for empty placeholders as part of validation.

## Terraform testing baseline
- For every behavioral change in `IDVH/<resource-module>` or `IDVH/01_idvh_loader`, add or update `.tftest.hcl` tests.
- Run `terraform test` for every touched IDVH module. When a suite is missing, create the minimal `.tftest.hcl` suite needed to validate the change.
- For every new IDVH module, create a minimal `.tftest.hcl` suite in the same change.
- Prefer mocked provider patterns for deterministic local tests when real cloud resources are not required.
- Keep tests focused on module contracts: required inputs, output values, and key conditional behaviors.
- Keep at least one negative-path assertion when introducing new validation checks.

## Documentation baseline
- Keep module `README.md` in sync with available tiers and example usage.
- Keep `LIBRARY.md` aligned with the catalog.
- Keep `resource_description.info` placeholders aligned with flattened YAML key names.
- Keep README module usage examples external (Git source), not local relative paths like `./IDVH/<module>`.
- Keep examples and defaults generic; avoid project-specific names in reusable module docs.

## Script baseline
- Keep full IDVH scripts under `IDVH/.scripts`.
- Use symlinks from module/test folders to shared scripts in `IDVH/.scripts` when needed.
- Keep shell script headers short: one-line purpose and one concise usage example with placeholders.

## Optional module references
- Load only the reference file that matches the target resource module when such files exist.
