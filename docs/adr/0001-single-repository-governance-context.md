# ADR-0001: Single repository governance context

* Status: accepted
* Date: 2026-09-01
* Deciders: Explicit execution approval recorded in the approved plan
* Related: [Repository context](../../CONTEXT.md)

## Context and Problem Statement

The repository declares a single-context documentation layout in
`docs/agents/domain.md`, but the root context, architecture document, and ADR
directory were absent. Current on-disk evidence shows repository-governance and
Copilot-customization vocabularies across root policy files, `.github` source
assets, scripts, workflows, and validation configuration. Six richer-domain
signals are present: distinct term meaning, representation, audience, tool
set, delivery boundary, and directional relationship.

## Decision Drivers

* Follow the repository-local documentation declaration.
* Avoid inventing a second domain from physical file or tool boundaries alone.
* Keep the knowledge layout understandable while the deleted implementation tree remains unresolved.

## Considered Options

* Keep one root context and repository-wide ADRs.
* Split the root policy and `.github` assets into separate contexts.
* Defer all context documentation until the deleted implementation tree is restored.

## Decision Outcome

Chosen option: "Keep one root context and repository-wide ADRs", as a
conditional single-context exception. The current worktree has the `IDVH/**`
tree absent through pre-existing deletions, while the README and policy
constraints forbid the coordinated migration needed to establish a coherent
second context. This is not a conclusion that all six richer-domain signals
are absent.

### Positive Consequences

* Readers have one glossary and one repository-wide decision location.
* The layout remains conservative and can be superseded if future evidence establishes multiple domains.

### Negative Consequences

* The boundary of the absent `IDVH` implementation cannot be recorded yet.
* A future domain split will require a superseding decision and coordinated
  document migration after the implementation tree's status is resolved.

## Pros and Cons of the Options

### Keep one root context and repository-wide ADRs

* Good, because it matches [docs/agents/domain.md](../agents/domain.md).
* Good, because current files share repository-governance terminology.
* Bad, because it does not answer the architecture of deleted implementation paths.

### Split the root policy and `.github` assets into separate contexts

* Good, because their file types and execution surfaces differ.
* Bad, because separate vocabulary, lifecycle, and bounded-context evidence is not established on disk.

### Defer all context documentation until the deleted implementation tree is restored

* Good, because it avoids claims about missing material.
* Bad, because it leaves the declared current layout unrealized and does not document the files that are present.
