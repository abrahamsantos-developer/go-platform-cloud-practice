# 08 · AWS Real

This module is intentionally a placeholder. The goal is to give you a safe checklist before you touch a real AWS account.

You should read this module before you provision anything outside LocalStack.

## What This Module Covers

- How to create a dedicated IAM user for Terraform and CLI work.
- Why you should never use the root account for daily work.
- Which free-tier assumptions are safe and which ones are not.
- Why EKS is usually the wrong first practice target.
- How to estimate costs before you run `terraform apply`.
- What to destroy before you log off.

## The Big Cost Trap: EKS Is Not Free

EKS charges for the control plane even when your workloads are tiny. That is roughly `$0.10/hour`, which is more than enough to burn money during practice.

If your goal is hands-on Kubernetes on AWS without surprise costs, start with one of these:

- EC2 + `k3s` on a small instance.
- Local `kind` for Kubernetes concepts, then AWS only for storage / IAM / networking.
- ECS Fargate if you want managed containers without managing a cluster.

For interview prep, it is completely acceptable to say:

> "I avoid EKS for initial sandbox practice because the control plane is not free. I start with LocalStack or EC2 + k3s, then move to managed services once the workflow is validated."

## `aws configure` Setup

Use a dedicated IAM user with programmatic access, not the root account.

Suggested steps:

1. Log in as the root account only once to enable MFA and create an admin group.
2. Create a dedicated IAM user for your sandbox work.
3. Attach the minimum policies you need for the exercise, or `AdministratorAccess` temporarily in a disposable sandbox account.
4. Generate an access key for CLI / Terraform use.
5. Run:

```bash
aws configure
```

Recommended answers:

```text
AWS Access Key ID:     <sandbox-user-access-key>
AWS Secret Access Key: <sandbox-user-secret>
Default region name:   us-east-1
Default output format: json
```

Verify it immediately:

```bash
aws sts get-caller-identity
```

The returned ARN should be your IAM user, not `root`.

## Free-Tier Notes

Free tier changes over time, so always confirm the live AWS pricing page first. As a rule of thumb:

- S3 is cheap, but storage, requests, and data transfer are still billable.
- EC2 free-tier eligibility depends on instance family and account age.
- Elastic IPs cost money when detached or left unused.
- NAT Gateways are almost never a good idea for free-tier practice.
- EKS control plane is not free.
- CloudWatch logs and metrics can quietly accumulate cost.

## Cost Estimation Habit

Before every real apply, write down the expected cost of each resource.

Example checklist:

| Resource | Typical practice choice | Cost note |
|---|---|---|
| S3 bucket | 1 bucket | Usually cheap, but requests and egress still matter |
| EC2 | `t3.micro` / `t2.micro` if eligible | Check free-tier eligibility first |
| ECR | 1 small image repo | Storage is cheap, but not zero |
| Route53 | 1 hosted zone | Flat monthly charge |
| NAT Gateway | Avoid for practice | Common hidden cost |
| EBS | Small root volume | Charged by provisioned size |

## Destroy Checklist

Before you finish a practice session:

1. Run `terraform destroy` from every real environment you created.
2. Check for leftover EC2 instances.
3. Check for EBS volumes and snapshots.
4. Check for Elastic IPs.
5. Check for load balancers.
6. Check for NAT Gateways.
7. Check for ECR repositories.
8. Check CloudWatch log groups if your module created them.
9. Re-run the AWS billing dashboard the next day.

## Folder Layout

- `01_broken/` is a placeholder for an unsafe first draft that still needs real values.
- `02_fixed/` is a placeholder for a cleaner version with guardrails and TODOs.

These files are intentionally incomplete so you can fill them in when you are ready to work against AWS for real.
