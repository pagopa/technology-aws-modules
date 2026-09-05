# Repository Scripts

These scripts provide the current bootstrap and Copilot customization validation entrypoints for the repository.

## Contents

- [Bootstrap](#bootstrap)
- [Validation](#validation)
- [Safety](#safety)

## Bootstrap

`bootstrap-copilot-config.sh` synchronizes a source `.github` directory into a target repository's `.github` directory. It performs a dry run by default, supports explicit `--apply`, and applies the source `.bootstrap-ignore` rules. Workflows are excluded unless `--include-workflows` is supplied.

```bash
.github/scripts/bootstrap-copilot-config.sh --target <repo-path>
```

## Validation

`validate-copilot-customizations.sh` validates Copilot customization files. The focused repository check is:

```bash
.github/scripts/validate-copilot-customizations.sh --scope root --mode strict
```

The validator can also produce a JSON report when a report path is supplied. Its scope is limited to the selected `.github` tree and does not replace repository-wide pre-commit checks.

## Safety

The bootstrap command is non-mutating unless `--apply` is provided. The `--clean` option requires `--apply` and can remove target files, so it is outside the normal preview path.

No diagram is provided because these two command entrypoints have no separate multi-component flow beyond the repository-wide flow documented in [../../docs/architecture.md](../../docs/architecture.md).
