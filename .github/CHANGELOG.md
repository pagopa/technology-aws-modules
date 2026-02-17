# Changelog

## Entry template
Use this format for new updates:
- `## YYYY-MM-DD`
- One bullet per meaningful change.
- Include file/path scope when useful.

## 2026-02-17
- Audited Copilot configuration for correctness, redundancy, and coherence.
- Removed IDVH addendum section from `copilot-instructions.md` (fully covered by `idvh.instructions.md`).
- Removed Script standards and Java/Node.js standards sections from `copilot-instructions.md` (covered by language-specific instruction files).
- Removed `scripts.instructions.md` (cross-cutting rules already in bash/python instructions and global config).
- Slimmed `skills/idvh-terraform/SKILL.md`: removed 17 duplicated mandatory rules, kept workflow and 2 unique rules with reference to `idvh.instructions.md`.
- Slimmed `skills/idvh-terraform/references/idvh-standards.md`: removed rules duplicated from `idvh.instructions.md`, kept unique architectural detail and rationale.
- Completed `AGENTS.md` with all 13 instruction files, 12 skills, and 12 prompts.
- Created `IDVH/.scripts/` directory with README for shared script convention.
- Added `idvh` profile to `repo-profiles.yml`.
- Confirmed `.github/PULL_REQUEST_TEMPLATE.md` exists with all required section headings.
- Added repository root `AGENTS.md` with explicit routing to Copilot instructions, IDVH standards, and reusable prompts/skills.
- Added IDVH-specific skill `.github/skills/idvh-terraform/SKILL.md` plus reference guide `.github/skills/idvh-terraform/references/idvh-standards.md`.
- Added IDVH auto-applied instruction file `.github/instructions/idvh.instructions.md`.
- Added reusable prompt `.github/prompts/cs-idvh-terraform.prompt.md` for create/modify/review workflows on `IDVH/**`.
- Refined `idvh-standards` to be fully cross-module with optional module references handled generically.

## 2026-02-07
- Added missing global Copilot instruction files for commit messages and code review.
- Added new instruction files: YAML, Markdown, Makefile, Scripts, Lambda.
- Added new skills: `terraform-module`, `cloud-policy`.
- Added `.github/README.md` and `AGENTS` template.
- Added custom agents: `Planner`, `Implementer`, `Reviewer`, `SecurityReviewer`, `WorkflowSupplyChain`, `TerraformGuardrails`, `IAMLeastPrivilege`.
- Added `.github/agents/README.md` with routing guidance.
- Hardened prompt/skill/instruction/agent validation and workflow checks.
- Added validator scope/mode support: `--scope root|all|repo=<name>` and `--mode strict|legacy-compatible`.
- Added validator JSON reporting support: `--report json --report-file <path>`.
- Added `repo-profiles.yml` for reusable high-level repository profiles.
- Added `security-baseline.md` and `DEPRECATION.md`.
- Added `instructions/composite-action.instructions.md` for reusable composite actions.
- Added `scripts/bootstrap-copilot-config.sh` for safe `.github` bootstrap and sync.
- Added `templates/copilot-quickstart.md` for portable onboarding.
- Added PR authoring assets: `prompts/cs-pr-description.prompt.md` and `skills/pr-writing/SKILL.md`.
- Updated docs to be repository-agnostic and reusable across different tech stacks.
- Replaced non-portable `PagoPA standards` wording with generic repository standards in script prompts.
- Hardened validator frontmatter key detection for multiline YAML keys.
- Extended validator JSON output with per-finding details.
- Added `prompts/cs-composite-action.prompt.md` and `skills/composite-action/SKILL.md`.
- Added `prompts/cs-data-registry.prompt.md` and `skills/data-registry/SKILL.md`.
- Expanded `cloud-policy` skill with concrete AWS/Azure/GCP templates.
- Reduced duplication by moving Java/Node examples from instructions to skills.
- Reduced overlap in `scripts.instructions.md` to cross-cutting rules only.
- Added bootstrap hardening (`--include-workflows`, `--exclude`, `--exclude-file`, `.bootstrap-ignore` support).
- Added `.github/CODEOWNERS` baseline and expanded Dependabot ecosystems.
- Enriched instruction files: composite action safety, Lambda specificity, YAML schema hint, Markdown language policy, Makefile example.
- Replaced placeholder `AGENTS.md` with repository-specific operational guidance in all `eng-*` repositories.
