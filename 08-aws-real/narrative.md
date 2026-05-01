# Narrative - Module 08 AWS Real

This module is based on the cloud-provider and Terraform parts of the HTML cheatsheet.

## The Story To Tell

> "For real cloud work, I separate learning environments from production-like environments. I use a dedicated IAM user, never the root account, estimate resource cost before apply, and always keep a destroy checklist. For Kubernetes practice on AWS, I do not start with EKS because the control plane is not free. I start with local Kubernetes or EC2 + k3s, then move to managed services when I actually need them."

## Why This Matters In Interviews

That answer shows four things interviewers care about:

- You understand cloud security hygiene.
- You think about cost before provisioning.
- You know the difference between a learning sandbox and a production platform.
- You can justify a cheaper path without sounding dogmatic.

## How It Connects To The Cheatsheet

- Terraform stays the infra-as-code control plane.
- AWS is one provider implementation, not a totally different mental model.
- The same service can still be packaged with Docker and deployed through Kubernetes or a simpler AWS runtime.
- Cross-cloud thinking means the provider-specific syntax changes, but the platform concepts stay the same.
