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

## Script standards (Bash/Python)
- Apply to both create and modify flows.
- Start with purpose + usage examples.
- Use emoji logs for state transitions.
- Use simple control flow and early returns.
- Bash: always `#!/usr/bin/env bash` (never POSIX `sh`).
- Python: add unit tests for testable logic.
- Python: if external dependencies are used, pin versions in `requirements.txt`.

## Java and Node.js standards
- Treat as project work (services/modules/components), not script work.
- Add a short purpose JavaDoc/comment when intent is not obvious.
- Keep unit tests simple and BDD-like.
- Java default: JUnit 5 with `@DisplayName` and `given_when_then` naming.
- Node default: built-in `node:test` + `node:assert/strict` (`describe`/`it` when available).

## Validation baseline
- Terraform: `terraform fmt` and `terraform validate`.
- Bash: `bash -n` and `shellcheck -s bash` (if available).
- Python/Java/Node.js: run unit tests relevant to the change.
- Run `.github/scripts/validate-copilot-customizations.sh` for customization changes.

## IDVH addendum
- For `IDVH/**`, enforce `.github/instructions/idvh.instructions.md` and the `idvh-terraform` skill standards.
- Use upstream Terraform modules from `github.com/terraform-aws-modules` with Git `source` pinned by commit hash.
- Add a numeric release URL comment above each pinned upstream module source (`.../releases/tag/vX.Y.Z`).
- Keep IDVH README examples external and generic (no local `./IDVH/...` sources and no project-specific names).
- Prefer splitting broad concerns into sibling modules under `IDVH/` instead of nested submodules.
- Keep each IDVH resource module independently consumable; avoid turning it into an orchestrator unless explicitly requested.
- Keep IDVH modules lean with pragmatic boundaries; avoid both monolithic wrappers and unnecessary module fragmentation.
- In IDVH catalog YAML, keep only reusable configuration settings and avoid project-specific identifiers/names as structural keys.
