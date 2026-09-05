# .github Configuration

This folder contains the Copilot customization source and GitHub automation currently present in this repository.

## Contents

- [Structure](#structure)
- [Maintenance workflow](#maintenance-workflow)
- [Validation](#validation)
- [Related documentation](#related-documentation)

## Structure

| Path | Responsibility | Notes |
| --- | --- | --- |
| `copilot-instructions.md` | Global Copilot review baseline | Applies to GitHub.com Copilot code review. |
| `instructions/` | Path-specific instruction files | The current set covers repository and language/tool conventions. |
| `scripts/` | Bootstrap and validation entrypoints | See [scripts/README.md](scripts/README.md). |
| `workflows/` | GitHub Actions automation | Includes pre-commit and pull-request title validation workflows. |
| `CHANGELOG.md` | Historical customization record | Use the existing entry format for notable changes. |
| `CODEOWNERS` | Ownership baseline for `.github` | Current owner is a placeholder team. |
| `dependabot.yml` | Dependency update configuration | Declares GitHub Actions, pip, npm, and Terraform ecosystems. |

## Maintenance workflow

Update the source asset under `.github/`, run the focused validator, and update [CHANGELOG.md](CHANGELOG.md) for a notable change. To preview synchronization into another repository, use:

```bash
.github/scripts/bootstrap-copilot-config.sh --target <repo-path>
```

The bootstrap script defaults to a dry run and applies the source ignore file. Use `--apply` only when the target is known and the resulting scope is intended.

## Validation

Run the validator from the repository root:

```bash
.github/scripts/validate-copilot-customizations.sh --scope root --mode strict
```

The `_pre-commit.yml` workflow runs the configured pre-commit hooks in a pinned container. The validator and workflow are separate checks with different coverage.

## Related documentation

- [Root repository README](../README.md)
- [Repository architecture](../docs/architecture.md)
- [Repository context](../CONTEXT.md)

No diagram is provided because the repository-wide relationships are owned by [../docs/architecture.md](../docs/architecture.md).
