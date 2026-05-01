# 06 · Terraform

This module demonstrates why Terraform state storage matters as soon as more than one process can touch the same infrastructure.

It uses LocalStack so you can practice S3 + DynamoDB state locking without touching a real AWS account.

## Broken Version

`01_broken/` uses local state only.

The demo launches two `terraform apply` commands at almost the same time with locking disabled. That is the whole danger:

- both commands believe they can proceed
- both can try to create or update the same resources
- the result depends on timing, not on policy

That is exactly how teams end up with corrupted or stale state.

## Fixed Version

`02_fixed/` has two layers:

- `bootstrap/` creates the backend bucket and lock table
- `stack/` stores state remotely in S3 and uses DynamoDB for locking

The demo then starts one apply and immediately starts a second one.

This time the second apply fails fast with a lock error instead of racing blindly.

## The Important Terraform Lesson

State is not just a file.
It is the coordination point for your infrastructure.

If the coordination point is local, every teammate is one bad command away from drift or corruption.
If the coordination point is remote and locked, Terraform can protect you from concurrent mutation.

## Bootstrap Caveat

You cannot use an S3 backend until the bucket and lock table already exist.

That is why the fixed version has a small bootstrap step first. This is a normal Terraform pattern, not a workaround.

## Run It

```bash
bash 06-terraform/demo.sh
```

## Notes

- The demo pins `localstack/localstack:4.14.0` because newer unified LocalStack images require an auth token.
- The demo pulls the LocalStack image once before timing the module.
- All resources are local and disappear when the LocalStack container is removed.
