# Narrative - Module 07 Cross-Cloud

## Cheatsheet Quotes

> "We ran the same service on two cloud providers. K8s manifests were identical - only ingress annotations and storage class differed."

> "The concepts are identical across providers - managed K8s, object storage, IAM, VPC networking. The syntax differs but the mental model is the same."

## The Story To Tell

> "I compared equivalent Terraform configs for AWS, GCP, and Azure side by side. The provider block and resource names changed, but the platform concept stayed the same: configure a provider, provision object storage, attach metadata, and handle naming constraints. Azure needed a storage account plus container, while AWS and GCP exposed a more direct bucket resource. Terraform made the portability story explicit: the cloud provider is mostly an implementation detail around the same infrastructure pattern."

## What This Module Teaches

- provider syntax is not the same thing as platform design
- cross-cloud work is mostly concept mapping
- Terraform makes the differences visible without changing the overall mental model
