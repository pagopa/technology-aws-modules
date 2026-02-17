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

## Instruction Files (auto-applied by path)
- `.github/instructions/bash.instructions.md` — `**/*.sh`
- `.github/instructions/composite-action.instructions.md` — `.github/actions/**/action.y*ml`
- `.github/instructions/github-actions.instructions.md` — `.github/workflows/**`
- `.github/instructions/idvh.instructions.md` — `IDVH/**/*.tf,IDVH/**/*.yml,IDVH/**/*.md,IDVH/**/*.sh,IDVH/**/*.py`
- `.github/instructions/java.instructions.md` — `**/*.java`
- `.github/instructions/json.instructions.md` — `**/authorizations/**/*.json,**/organization/**/*.json,**/src/**/*.json,**/data/**/*.json`
- `.github/instructions/lambda.instructions.md` — `**/*lambda*.tf,**/*lambda*.py,**/*lambda*.js,**/*lambda*.ts`
- `.github/instructions/makefile.instructions.md` — `**/Makefile,**/*.mk`
- `.github/instructions/markdown.instructions.md` — `**/*.md`
- `.github/instructions/nodejs.instructions.md` — `**/*.js,**/*.cjs,**/*.mjs,**/*.ts,**/*.tsx`
- `.github/instructions/python.instructions.md` — `**/*.py`
- `.github/instructions/terraform.instructions.md` — `**/*.tf`
- `.github/instructions/yaml.instructions.md` — `**/*.yml,**/*.yaml`

## Available Skills
- `.github/skills/cicd-workflow/SKILL.md`: secure GitHub Actions workflow patterns.
- `.github/skills/cloud-policy/SKILL.md`: governance policies for AWS SCP, Azure Policy, GCP Org Policy.
- `.github/skills/composite-action/SKILL.md`: reusable GitHub composite actions.
- `.github/skills/data-registry/SKILL.md`: structured JSON/YAML registry updates.
- `.github/skills/idvh-terraform/SKILL.md`: IDVH catalog-driven Terraform standards and workflow.
- `.github/skills/pr-writing/SKILL.md`: pull request description generation.
- `.github/skills/project-java/SKILL.md`: Java project components with BDD tests.
- `.github/skills/project-nodejs/SKILL.md`: Node.js project modules with BDD tests.
- `.github/skills/script-bash/SKILL.md`: Bash scripts with purpose header and emoji logs.
- `.github/skills/script-python/SKILL.md`: Python scripts with docstring, tests, and pinned deps.
- `.github/skills/terraform-feature/SKILL.md`: Terraform resource/variable/output updates.
- `.github/skills/terraform-module/SKILL.md`: reusable Terraform module structure.

## Available Prompts
- `.github/prompts/cs-add-unit-tests.prompt.md`: add unit tests for Python, Java, or Node.js.
- `.github/prompts/cs-bash-script.prompt.md`: create or modify Bash scripts.
- `.github/prompts/cs-cloud-policy.prompt.md`: create or modify cloud governance policies.
- `.github/prompts/cs-composite-action.prompt.md`: create or modify composite actions.
- `.github/prompts/cs-data-registry.prompt.md`: update structured JSON/YAML registries.
- `.github/prompts/cs-github-action.prompt.md`: create or modify GitHub Actions workflows.
- `.github/prompts/cs-idvh-terraform.prompt.md`: create/modify/review IDVH modules and catalog.
- `.github/prompts/cs-java.prompt.md`: create or modify Java project components.
- `.github/prompts/cs-nodejs.prompt.md`: create or modify Node.js project modules.
- `.github/prompts/cs-pr-description.prompt.md`: PR description generation.
- `.github/prompts/cs-python-script.prompt.md`: create or modify Python scripts.
- `.github/prompts/cs-terraform.prompt.md`: generic Terraform implementation tasks.

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

