# Narrative - Module 06 Terraform

## Cheatsheet Quote

> "I used Terraform to provision cloud infrastructure ... State stored remotely with locking to prevent concurrent modifications."

## The Story To Tell

> "I reproduced the difference between local state and remote state with locking using LocalStack. In the broken version, two applies were allowed to start at the same time because there was no shared remote lock. In the fixed version, I bootstrapped an S3 state bucket and a DynamoDB lock table, moved the stack to the S3 backend, and then proved that the second apply failed fast with a state lock error. The key idea is that Terraform state is a coordination system, not just an output file."

## Short Follow-Up

- local state is fine for solo throwaway work
- remote state is required for team workflows
- locking is what stops concurrent mutation from becoming state corruption
- backend resources need a one-time bootstrap step before the main stack can use them
