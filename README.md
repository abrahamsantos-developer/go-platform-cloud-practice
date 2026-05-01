# Go Platform & Cloud - Mini Practice

Local end-to-end practice repo for the platform / infra stack around a Go service: from Dockerfiles to a real AWS-ready Terraform skeleton.

> Philosophy: **Break > Understand > Fix > Repeat.**
> Every module includes something that fails on purpose, the fix next to it, and a short hands-on path so you can break it again yourself.

---

## The Shared Service

The whole repo revolves around one small Go service in `service/` that we carry through the whole stack:

```diagram
service/main.go     <- Go HTTP: /healthz + /count
   │
   ├──[01]──▶ docker build         ──▶ container image
   ├──[02]──▶ docker compose up    ──▶ local stack with Postgres + Redis
   ├──[03]──▶ kind + kubectl apply ──▶ pod in a local cluster
   ├──[04]──▶ helm install         ──▶ versioned release with per-env values
   ├──[05]──▶ GitLab CI pipeline   ──▶ lint + test + build + deploy
   ├──[06]──▶ terraform apply      ──▶ infrastructure as code via LocalStack
   ├──[07]──▶ cross-cloud          ──▶ AWS vs GCP vs Azure Terraform patterns
   └──[08]──▶ AWS real             ──▶ free tier notes, costs, destroy checklist
```

---

## Module Map

| # | Module | Question it answers |
|---|--------|------------------------|
| 01 | [Docker](./01-docker/) | Why is my image 800MB instead of 10MB? |
| 02 | [Compose](./02-compose/) | How do I bring up the whole stack on my laptop? |
| 03 | [Kubernetes](./03-kubernetes/) | Why is my Pod stuck in `Pending` or never `Ready`? |
| 04 | [Helm](./04-helm/) | How do I manage dev / staging / prod from one chart? |
| 05 | [CI/CD](./05-cicd/) | How do I automate lint -> test -> build -> deploy? |
| 06 | [Terraform](./06-terraform/) | How do I provision infra reproducibly and lock state? |
| 07 | [Cross-cloud](./07-cross-cloud/) | AWS vs GCP vs Azure: what changes and what does not? |
| 08 | [AWS real](./08-aws-real/) | Placeholder guide for real AWS free-tier practice |

---

## Verified Tooling On Your Machine

```bash
docker version       # ≥ 24
docker compose version
kubectl version --client
kind --version
helm version
golangci-lint version
terraform version
aws --version
go version           # ≥ 1.22
```

---

## Key Commands

```bash
# Build the image (module 01)
docker build -f 01-docker/01_naive/Dockerfile -t goose:naive .
docker images | grep goose

# Run the break/fix Compose walkthrough (module 02)
bash 02-compose/demo.sh

# Run the Kubernetes rollout failures + fix (module 03)
bash 03-kubernetes/demo.sh

# Run the Helm install -> upgrade -> rollback flow (module 04)
bash 04-helm/demo.sh

# Simulated local pipeline (module 05)
bash 05-cicd/demo.sh

# Terraform state walkthrough with LocalStack (module 06)
bash 06-terraform/demo.sh

# Cross-cloud comparison (module 07)
diff -u 07-cross-cloud/aws/main.tf 07-cross-cloud/gcp/main.tf
```

---

## Module Layout

Modules 02-06 follow the same break/fix structure:

```
NN-module/
├── README.md         <- theory + broken scenario + why the fix works
├── 01_broken/        <- intentionally broken config
├── 02_fixed/         <- working version
├── demo.sh           <- runs broken -> fix -> success
└── narrative.md      <- interview-ready wording grounded in the cheatsheet
```

Module 01 keeps its original `exercises.md` workflow because it was built first, but the philosophy is the same: break it, understand it, fix it, repeat.

Module 07 is intentionally comparison-only (`aws/`, `gcp/`, `azure/` side by side) and module 08 is intentionally placeholder-only for real AWS practice.

---

Start with [`01-docker/`](./01-docker/).
