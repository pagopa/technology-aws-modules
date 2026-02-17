## Summary
Describe what changed and why.

## Scope
- [ ] Terraform modules
- [ ] IDVH product configuration (`IDVH/00_product_configs/*`)
- [ ] Repository automation (`.github/*`, including workflows/prompts/skills/instructions)
- [ ] Scripts (`.scripts/*`, `IDVH/.scripts/*`, Bash/Python helpers)
- [ ] Documentation and governance (`*.md`, `CODEOWNERS`, `.gitignore`)
- [ ] Other

## Changes
List the key changes in bullet points:
- 
- 

## Validation
Describe what you ran and the results.

```bash
# Preferred for Terraform changes:
# from each changed Terraform module directory, run the local wrapper
./terraform.sh

# If a local terraform wrapper is not available, run equivalent checks:
terraform fmt -check -recursive
terraform init -backend=false -no-color
terraform validate -no-color
terraform test -test-directory=tests -no-color

# If repository scripts changed:
bash -n <script>.sh
shellcheck -s bash <script>.sh

# If .github/* changed:
.github/scripts/validate-copilot-customizations.sh --scope root --mode strict
```

## Security and Compliance
- [ ] Least privilege preserved (IAM roles/policies/resources reviewed)
- [ ] No hardcoded secrets/tokens
- [ ] External dependencies pinned appropriately (providers/modules/actions)
- [ ] Actions pinned to full-length SHA (if workflows changed)
- [ ] Data/network impact reviewed
- [ ] Breaking changes reviewed and communicated

## Risk and Rollback
- **Risk level**: Low / Medium / High
- **Blast radius**: Which modules/environments/resources are affected
- **Rollback plan**: Explain exact, safe revert steps

## Related Links
- Issue:
- Docs:
- Runbook:

## Reviewer Notes
Anything reviewers should focus on first (critical files, expected plan deltas, known limitations).
