# Architectural Decision Records

Repository-wide architectural decisions live in this directory.

## Index

- [ADR 0001: Single repository governance context](0001-single-repository-governance-context.md) - proposed documentation layout decision.

## Format

- Files use the form `NNNN-<slug>.md`.
- Each record uses the headings `Context and Problem Statement`, `Decision Drivers`, `Considered Options`, `Decision Outcome`, and `Pros and Cons of the Options`.
- Status values are `draft`, `proposed`, `rejected`, `accepted`, `deprecated`, and `superseded by ADR-NNNN`.
- Accepted decision bodies are immutable. A changed accepted decision requires a new ADR that supersedes the earlier record.

No diagram is provided because this index records decision navigation; the repository topology is documented in [../architecture.md](../architecture.md).

## Validation

Before accepting a record, verify its index link, required headings, and
status against the format above. Run the repository documentation checks when
they are available.
