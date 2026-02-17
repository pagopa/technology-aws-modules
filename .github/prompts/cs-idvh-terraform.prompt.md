---
description: Create, refactor, or review IDVH Terraform modules and YAML tiers using catalog-first standards
name: cs-idvh-terraform
agent: agent
argument-hint: action=<create|modify|review> area=<loader|resource_module|catalog|docs> objective=<text> target_path=<path>
---

# IDVH Terraform Task

## Required inputs
- **Action**: ${input:action:create,modify,review}
- **Area**: ${input:area:loader,resource_module,catalog,docs}
- **Objective**: ${input:objective}
- **Target path**: ${input:target_path}

## Instructions
1. Use `.github/skills/idvh-terraform/SKILL.md`.
2. Reuse existing IDVH patterns before introducing new abstractions.
3. Keep structural behavior in YAML tiers and expose only dynamic inputs as Terraform variables.
4. Keep validation locals and `check` blocks in `checks.tf`.
5. Keep YAML catalog clean (no empty-string placeholders).
6. Keep technical content and docs in English.
7. If `action=review`, report findings first by severity, then propose minimal targeted fixes.

## Minimal example
- Input: `action=modify area=resource_module objective="add tier key and validation for lifecycle defaults" target_path=IDVH/<resource-module>`
- Expected output:
  - Updated YAML schema contract and checks under `checks.tf`.
  - Minimal `main.tf` changes only for effective value wiring.
  - Matching docs update if tier behavior changed.

## Validation
- Run `terraform fmt` on touched files.
- Run `terraform validate` for touched modules when provider access is available.
- Run `rg -n ':\s*\"\"\s*$' IDVH/00_product_configs` and ensure no matches.
- Confirm README/LIBRARY examples remain aligned with actual catalog keys.
