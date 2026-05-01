# 04 · Helm

This module wraps the Kubernetes manifests from module 03 in a Helm chart.

## The Broken Case

`01_broken/chart/` contains a template typo.

That is intentional. The point is to feel the difference between:

- a Kubernetes manifest problem
- a Helm rendering problem

If Helm cannot render the chart, the cluster never even sees a valid manifest.

## The Fixed Case

`02_fixed/chart/` gives you:

- one chart
- default values
- `values/dev.yaml`
- `values/staging.yaml`
- `values/prod.yaml`

The same templates deploy the same service into different environments with different replica counts and resource settings.

## Why Helm Exists

Raw manifests are fine when you have one service and one environment.
Helm starts paying for itself when you need:

- repeatable releases
- release history
- rollback
- per-environment values
- cross-cloud portability via values files instead of chart rewrites

## Demo Flow

`demo.sh` does four things:

1. shows the broken chart fail during render/install
2. installs the fixed chart with dev values
3. upgrades the same release to prod values
4. rolls back to revision 1

That is the exact muscle memory interviewers want to hear when they ask about Helm.

## Run It

```bash
bash 04-helm/demo.sh
```
