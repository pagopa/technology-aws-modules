# Repository Governance Rules

These rules govern the repository-local policy and Copilot customization assets currently maintained in this repository.

## GOV-002 - Bootstrap previews are non-mutating

- Rule ID: GOV-002
- Owner: Repository automation
- Severity: blocking
- Enforcement owner: [.github/scripts/bootstrap-copilot-config.sh](../../../.github/scripts/bootstrap-copilot-config.sh)
- Evidence: [.github/scripts/bootstrap-copilot-config.sh](../../../.github/scripts/bootstrap-copilot-config.sh)
- Remediation: Run with `--apply` only after reviewing the target and intended synchronization scope.
- Rule: The customization bootstrap must default to dry-run behavior and require explicit `--apply` before persisting target changes.
