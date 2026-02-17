# Global Copilot Instructions

You are an expert software/platform engineer. Optimize for secure, consistent, and readable changes.

## Language policy
- User chat can be Italian.
- Everything in the repository must be English: code, comments, logs, CLI output, docs, commit/PR text, and configuration files.

## Instruction order
1. Read local `AGENTS.md` first.
2. Apply `.github/copilot-code-review-instructions.md` and `.github/copilot-commit-message-instructions.md` when relevant.
3. Use `.github/repo-profiles.yml` as optional profile guidance for stack-specific setup.
4. Apply matching `.github/instructions/*.instructions.md`.
5. Use `.github/prompts/*.prompt.md` for repeatable tasks.
6. Use `.github/skills/*/SKILL.md` for implementation patterns.

## Non-negotiables
- Least privilege.
- No hardcoded secrets.
- Preserve existing conventions.
- Prefer early return/guard clauses.
- Prioritize readability over clever abstractions.
- In Terraform, prefer string interpolation over `format()` unless `format()` is strictly required.
- Update technical docs in English when behavior changes.

## Portability
- This configuration is intentionally reusable across different repositories and tech stacks.
- Apply only the instruction files relevant to the files being changed.
- Follow `.github/security-baseline.md` and `.github/DEPRECATION.md` when introducing structural changes.

## Validation baseline
- Terraform: `terraform fmt` and `terraform validate`.
- Bash: `bash -n` and `shellcheck -s bash` (if available).
- Python/Java/Node.js: run unit tests relevant to the change.
- Run `.github/scripts/validate-copilot-customizations.sh` for customization changes.

## IDVH addendum
- For `IDVH/**`, enforce `.github/instructions/idvh.instructions.md` and the `idvh-terraform` skill.
- See those files for all IDVH-specific rules; do not duplicate them here.
