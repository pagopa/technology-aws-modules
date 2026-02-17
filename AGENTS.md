# AGENTS.md - technology-aws-modules

This file is for AI assistants and GitHub Copilot working in this repository.

## Main Instructions
- Read `.github/copilot-instructions.md` first.
- Apply relevant path-specific files under `.github/instructions/`.
- For `IDVH/**` changes, always apply `.github/instructions/idvh.instructions.md`.

## Configuration Files
- `.github/copilot-instructions.md`
- `.github/copilot-code-review-instructions.md`
- `.github/copilot-commit-message-instructions.md`
- `.github/instructions/terraform.instructions.md`
- `.github/instructions/idvh.instructions.md`

## Available Skills
- `.github/skills/idvh-terraform/SKILL.md`: IDVH catalog-driven Terraform standards and workflow.
- `.github/skills/terraform-module/SKILL.md`: generic reusable Terraform module structure.
- `.github/skills/terraform-feature/SKILL.md`: generic Terraform resource/variable/output updates.

## Available Prompts
- `.github/prompts/cs-idvh-terraform.prompt.md`: create/modify/review IDVH modules and catalog.
- `.github/prompts/cs-terraform.prompt.md`: generic Terraform implementation tasks.
- `.github/prompts/cs-pr-description.prompt.md`: PR description generation.

## Conventions
- User chat may be Italian, repository content must be English.
- Keep Terraform identifiers in `snake_case`.
- Keep structural IDVH behavior in YAML tiers.
- Keep validation contracts in `checks.tf`.
- Keep dynamic overrides explicit and minimal.

## Prohibitions
- Do not hardcode secrets, account-specific IDs, or environment-specific values in module logic.
- Do not add empty-string placeholders in IDVH YAML catalog.
- Do not bypass validation when adding tier keys or nested schema fields.

