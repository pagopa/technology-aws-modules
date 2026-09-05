# technology-aws-modules

This repository currently contains repository-governance policy and reusable GitHub Copilot customization assets. The infrastructure tree recorded by Git is currently absent from the worktree and is not described as active architecture here.

## Contents

- [Purpose](#purpose)
- [Repository map](#repository-map)
- [Change path](#change-path)
- [Validation](#validation)
- [Related documentation](#related-documentation)

## Purpose

Use this repository to maintain the local operating policy, Copilot customization source, repository automation, and validation configuration that are present on disk.

## Repository map

| Path | Responsibility | Notes |
| --- | --- | --- |
| `AGENTS.md` | Portable agent operating baseline | Read before repository changes. |
| `AGENTS.local.md` | Local standards-repository policy | Defines local documentation and asset ownership. |
| `.github/` | Copilot customization and GitHub automation | Contains instructions, scripts, workflows, and repository metadata. |
| `docs/agents/` | Agent-facing local guidance | Includes the single-context documentation declaration. |
| `.pre-commit-config.yaml` | Repository validation configuration | Includes repository hygiene, shell, Python, Terraform, and workflow hooks. |

## Change path

1. Read [AGENTS.md](AGENTS.md), [AGENTS.local.md](AGENTS.local.md), and [docs/agents/domain.md](docs/agents/domain.md).
2. Keep Copilot source assets under `.github/` and use the documented bootstrap script when synchronizing them to another repository.
3. Preserve unrelated worktree changes, especially the currently deleted `IDVH/**` paths.
4. Update the relevant knowledge document when a structural or governance boundary changes.

## Validation

The repository workflow runs pre-commit against all files. For `.github` changes, the documented focused check is:

```bash
.github/scripts/validate-copilot-customizations.sh --scope root --mode strict
```

The local pre-commit configuration also defines safe syntax and policy checks. Terraform checks are configured, but no Terraform source is currently present in the worktree.

## Related documentation

- [Repository context](CONTEXT.md)
- [Architecture](docs/architecture.md)
- [Repository governance rules](docs/domain/repository-governance/RULES.md)
- [Architectural decisions](docs/adr/README.md)

No diagram is provided because the repository-wide component relationships are documented in [docs/architecture.md](docs/architecture.md).
