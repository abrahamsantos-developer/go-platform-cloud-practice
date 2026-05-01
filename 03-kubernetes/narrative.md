# Narrative - Module 03 Kubernetes

## Cheatsheet Quotes

> "Pushed a new version and the rollout stalled. Pods stuck in Pending. Resource requests were set too high - cluster didn't have enough allocatable CPU."

> "Service was getting traffic before it was ready - still warming up its DB connection pool. Fixed by implementing a /healthz endpoint that returns 200 only once the pool is initialized."

## The Story To Tell

> "I reproduced both failure modes locally in `kind`. First I deployed a Pod with absurd requests, so it stayed in `Pending` and `kubectl describe pod` showed the scheduler could not place it. Then I fixed the resources but broke the readiness probe path, so the container ran while the Pod stayed `0/1 Ready`. The final fix was realistic resource requests plus a readiness probe against `/healthz`. The main lesson is that scheduling and readiness are different contracts, and you need to debug them differently."

## Short Version

- `Pending` usually means the scheduler cannot place the Pod.
- `Running` but not `Ready` usually means the container is up but the service contract is still failing.
- `kubectl describe pod` is still one of the highest-value commands in the whole platform stack.
