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
2. Read `.github/skills/idvh-terraform/references/idvh-standards.md` for architecture and baseline details.
3. Read optional module references under `references/*-module.md` only when they exist for the target module.
4. Apply all rules from `.github/instructions/idvh.instructions.md` (auto-applied for `IDVH/**`).
5. Keep naming, tags, and security defaults consistent with existing IDVH modules.
6. Add or update `.tftest.hcl` coverage for every changed module contract, check, or conditional behavior.
7. Update docs when tier behavior, keys, outputs, or module-source references change.

## Additional rules
These complement `.github/instructions/idvh.instructions.md` (not duplicated here):
- Keep Terraform variable surfaces small and explicit.
- For every new validation check, include at least one negative-path `.tftest.hcl` assertion.

## Validation
- `terraform fmt` on touched module files.
- `terraform validate` for touched modules when provider access is available.
- `terraform test` for touched IDVH modules; if a module has no suite yet, add the minimal `.tftest.hcl` coverage needed for the change.
- `rg -n ':\s*\"\"\s*$' IDVH/00_product_configs` to prevent empty catalog values.
- Confirm docs and examples reflect new keys and behavior.
