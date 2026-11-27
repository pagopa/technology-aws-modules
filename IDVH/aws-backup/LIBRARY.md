# AWS Backup tiers

The `aws-backup` catalog provides `standard` in dev, uat and prod.
See [README](README.md#catalog) for retention and DR behavior.
Non-production uses shorter retention and less sensitive Coverage checks;
daily backups, GOVERNANCE locks and event alerts remain enabled.

One wrapper applies snapshot, Vault Lock, additional-rule, PITR, restore-testing
and optional Alerting/Coverage defaults. Explicit consumer overrides win.
See [override inputs](README.md#defaults-and-overrides).

Implementation remains in the
[source library](https://github.com/pagopa/eng-cloud-strategy-hub/tree/d30c3641dcb68628d9a67f1807ec4c06f3772064/terraform/aws/modules).
Only the catalog-driven wrapper is maintained here.
