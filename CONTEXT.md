# Repository Governance Context

This context defines the repository-specific terms used by the current
repository-governance and Copilot customization assets. The two vocabularies
remain in one context because the current worktree does not authorize a
coherent multi-context migration.

## Language

**Repository-local policy**:
Rules and operating guidance that apply to this repository in addition to shared agent behavior.
_Avoid_: global policy, personal preference

**Source-managed AI asset**:
A Copilot instruction, prompt, skill, agent, or related configuration file maintained as source content under `.github/`.
_Avoid_: generated output, runtime configuration

**Customization bootstrap**:
The dry-run-by-default synchronization of source-managed AI assets into another repository's `.github/` directory.
_Avoid_: deployment, installation

**Validation profile**:
The named strictness setting used by the Copilot customization validator, such as `strict` or `legacy-compatible`.
_Avoid_: repository environment, runtime mode

**Knowledge artifact**:
A durable repository document that records context, architecture, rules, or an architectural decision.
_Avoid_: scratch note, generated report

**Repository governance**:
The policy, validation, workflow, and maintenance boundary for the files
currently present in this repository.
_Avoid_: IDVH implementation behavior, live infrastructure

**Copilot customization**:
The source-managed instruction, skill, agent, prompt, and bootstrap vocabulary
maintained under `.github/`.
_Avoid_: generated consumer output, absent IDVH behavior
