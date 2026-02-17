---
name: idvh-terraform
description: Implement or refactor IDVH Terraform modules with catalog-driven tiers, strict YAML checks, and minimal dynamic overrides. Use when changing files under IDVH/<resource-module>, IDVH/01_idvh_loader, or IDVH/00_product_configs.
---

# IDVH Terraform Skill

## When to use
- Create a new IDVH wrapper module.
- Refactor an existing IDVH resource module or `IDVH/01_idvh_loader`.
- Add or modify tier values under `IDVH/00_product_configs/**`.
- Align module logic with catalog-first behavior and YAML validation checks.
- Update IDVH documentation (`README.md`, `LIBRARY.md`, `resource_description.info`) after behavior changes.

## Workflow
1. Detect the target area: loader, module, catalog, or docs.
2. Read `.github/skills/idvh-terraform/references/idvh-standards.md`.
3. Read optional module references under `references/*-module.md` only when they exist for the target module.
4. Keep structural settings in YAML tiers, not in Terraform variables.
5. Keep only true dynamic overrides in module inputs.
6. Validate YAML schema with `check` blocks and keep validation locals in `checks.tf`.
7. Keep naming, tags, and security defaults consistent with existing IDVH modules.
8. Keep upstream module sources pinned to commit hashes from `github.com/terraform-aws-modules` and annotate each source with the numeric release URL comment.
9. Add or update `.tftest.hcl` coverage for every changed module contract, check, or conditional behavior.
10. Update docs when tier behavior, keys, outputs, or module-source references change.

## Mandatory rules
- Use the loader triplet `product_name`, `env`, `idvh_resource_tier` plus `idvh_resource_type`.
- Keep loader merge order: global common, product common, env specific.
- Keep empty YAML parameters out of catalog files. Omit optional keys instead of using empty strings.
- Keep `required_*` and `missing_*` validation locals in `checks.tf`.
- Keep module `main.tf` focused on value composition and resource wiring.
- Keep Terraform variable surfaces small and explicit.
- Keep module source pins deterministic with Git commit hashes from `github.com/terraform-aws-modules`.
- Add a `Release URL` comment above each pinned source using `.../releases/tag/vX.Y.Z`.
- Keep README usage examples external (Git source), not local `./IDVH/<module>` paths.
- Keep docs/examples generic and avoid product-specific names from existing projects.
- Keep full IDVH script implementations in `IDVH/.scripts`; expose them to modules/tests with symlinks.
- For every behavioral change in `IDVH/<resource-module>` or `IDVH/01_idvh_loader`, add or update `.tftest.hcl` tests and include at least one negative-path assertion when new checks are introduced.
- Keep repository files in English.

## Validation
- `terraform fmt` on touched module files.
- `terraform validate` for touched modules when provider access is available.
- `terraform test` for touched IDVH modules; if a module has no suite yet, add the minimal `.tftest.hcl` coverage needed for the change.
- `rg -n ':\s*\"\"\s*$' IDVH/00_product_configs` to prevent empty catalog values.
- Confirm docs and examples reflect new keys and behavior.
