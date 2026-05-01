# 07 · Cross-Cloud

This module is a comparison module, not a break/fix demo.

The practice here is to read and diff the Terraform files side by side until the cloud-specific names stop feeling magical.

## Goal

Provision the same broad concept across three providers:

- AWS -> S3 bucket
- GCP -> GCS bucket
- Azure -> Blob storage inside a storage account

The syntax changes.
The mental model does not.

## How To Practice

Open these three files together:

- `aws/main.tf`
- `gcp/main.tf`
- `azure/main.tf`

Then ask yourself:

- where do provider credentials enter?
- what is the object storage resource called?
- which names must be globally unique?
- what tags / labels / metadata exist?
- which extra Azure resource exists only because Azure models storage differently?

## Comparison Table

| Concept | AWS | GCP | Azure |
|---|---|---|---|
| Managed Kubernetes | EKS | GKE | AKS |
| Object storage | S3 | GCS | Blob Storage |
| Container registry | ECR | Artifact Registry | ACR |
| Managed Postgres | RDS | Cloud SQL | Azure Database for PostgreSQL |
| Secrets | Secrets Manager | Secret Manager | Key Vault |
| Workload identity | IRSA | Workload Identity | Pod Identity / Entra ID |
| Monitoring | CloudWatch | Cloud Monitoring | Azure Monitor |

## What To Notice

AWS and GCP expose object storage as a single obvious resource.
Azure usually makes you think in two layers:

- storage account
- blob container

That is exactly the kind of provider-specific detail Terraform makes explicit.

## Useful Commands

```bash
diff -u 07-cross-cloud/aws/main.tf 07-cross-cloud/gcp/main.tf
diff -u 07-cross-cloud/aws/main.tf 07-cross-cloud/azure/main.tf
```

## Why This Module Exists

The cheatsheet makes a strong cross-cloud point: the concepts stay stable even when service names change.

This module is where you train that mental translation.
