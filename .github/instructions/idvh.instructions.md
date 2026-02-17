---
applyTo: "IDVH/**/*.tf,IDVH/**/*.yml,IDVH/**/*.md,IDVH/**/*.sh,IDVH/**/*.py"
---

# IDVH Instructions

## Design model
- Treat IDVH modules as catalog-driven wrappers.
- Keep baseline behavior in YAML tiers and keep Terraform inputs minimal.
- Keep loader usage consistent with `product_name`, `env`, `idvh_resource_tier`, and `idvh_resource_type`.

## YAML catalog rules
- Keep YAML keys explicit and type-consistent across environments.
- Omit empty optional keys instead of using empty strings.
- Keep env-specific files focused on true differences only.
- Preserve nested object schema contracts used by `check` blocks.
- Keep catalog values generic and reusable; avoid project-specific names/identifiers as structural configuration.

## Module implementation rules
- Keep validation locals and `check` blocks in `checks.tf`.
- Keep `main.tf` focused on value composition and resource wiring.
- Use direct `var override` or `YAML value` patterns for effective settings.
- Avoid hardcoded environment/account specific values.
- Preserve output contract stability for downstream modules.
- Prefer sibling modules under `IDVH/` for domain decomposition; avoid nested submodules unless explicitly requested.
- Keep each module independently consumable and single-responsibility; do not convert it into an orchestrator by default.
- Keep modules as lean as practical: avoid bloated wrappers, but also avoid over-fragmentation that harms usability and maintenance.
- Prefer string interpolation over `format()` in Terraform expressions unless `format()` is strictly necessary.
- For upstream module dependencies, use only `git::https://github.com/terraform-aws-modules/terraform-aws-<module>.git?ref=<commit-hash>`.
- Do not use Terraform Registry shorthand sources such as `terraform-aws-modules/<name>/aws`.
- Add a comment directly above each pinned `source` with the numeric release URL: `https://github.com/terraform-aws-modules/<repo>/releases/tag/vX.Y.Z`.

## Documentation and examples
- In module `README.md` examples, show external module usage (Git source) and do not use local paths such as `source = "./IDVH/<module>"`.
- Keep examples and placeholders generic; do not include product-specific names from existing projects (for example `onemail`).

## IDVH scripts
- Keep full IDVH script implementations in `IDVH/.scripts`.
- Reference shared script entrypoints from modules/tests via symlinks instead of duplicate wrappers or aliases.
- At the top of each shell script, keep a short purpose comment and one concise usage example with placeholders.

## Security and governance
- Keep least-privilege IAM actions and scoped resources where possible.

- Do not introduce secret values in Terraform code or YAML catalog.

## Validation
- Run `terraform fmt` for touched module files.
- Run `terraform validate` for touched modules when possible.
- For every behavioral change in `IDVH/<resource-module>` or `IDVH/01_idvh_loader`, add or update `.tftest.hcl` coverage for the changed contract.
- Run `terraform test` for touched IDVH modules; when a suite is missing, add the minimal suite required to validate the change.
- When adding a new IDVH module, include a minimal `.tftest.hcl` suite for that module in the same change.
- Run terraform.sh for end-to-end validation of changes.
- Scan catalog changes with `rg -n ':\s*\"\"\s*$' IDVH/00_product_configs`.
- Update README/LIBRARY when catalog keys or tier behavior changes.
