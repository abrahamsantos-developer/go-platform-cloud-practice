# 03 · Kubernetes

This module shows two of the most common rollout bugs you get asked about in interviews.

## Broken Example A: Pod Stuck In `Pending`

`01_broken/01_pending.yaml` asks for absurd resources:

- `cpu: 100`
- `memory: 100Gi`

On a small local cluster, the scheduler cannot place that Pod anywhere. The rollout stalls before the container even starts.

The lesson is simple: **resource requests are a scheduling contract**. If they are unrealistic, the cluster cannot help you.

## Broken Example B: Pod Runs But Never Becomes `Ready`

`01_broken/02_bad_readiness.yaml` fixes the resources, but points the readiness probe at the wrong path.

The container runs.
The Pod stays `0/1 Ready`.
The Service should not send traffic.

That is a different failure mode from `Pending`, and you should be able to explain both.

## Fixed Version

`02_fixed/` uses:

- realistic requests and limits
- a readiness probe against `/healthz`
- a Service exposing the app cleanly

## Why This Matters

This module maps directly to the cheatsheet scenarios:

- rollout stalled because requests were too high
- service received traffic before readiness was real

Kubernetes is mostly about making these contracts explicit.

## Run It

```bash
bash 03-kubernetes/demo.sh
```

## Notes

- The demo creates a `kind` cluster named `goose-k8s`.
- The first run can take about 30 seconds because the node image may need to download.
- The demo loads the local `goose:multi` image into the cluster for you.
