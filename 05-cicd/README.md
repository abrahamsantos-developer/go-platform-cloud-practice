# 05 · CI/CD

This module simulates a GitLab pipeline for the same Go service.

## The Pipeline Shape

The HTML cheatsheet calls out a very standard sequence:

- lint
- test
- build
- deploy

That is exactly what this module implements.

## Broken Version

`01_broken/` keeps the pipeline stages, but the test stage includes a deliberate data race.

The result is useful because it fails for a real engineering reason:

- lint passes
- race-enabled tests fail
- the pipeline stops before build and deploy

That is what you want from CI: catch unsafe code before you ship it.

## Fixed Version

`02_fixed/` replaces the racy fixture with a synchronized version and runs the same stages successfully.

The deploy step is still local-only. It renders the Helm chart you built in module 04 rather than touching a real cluster. That keeps the practice loop fast.

## Files

- each version has its own `.gitlab-ci.yml`
- each version has its own `run-locally.sh`
- each version has a tiny Go fixture used by the test stage
- `demo.sh` runs broken first, then fixed

## Run It

```bash
bash 05-cicd/demo.sh
```

## What To Watch For

In the broken pipeline, the race detector is the important line.

In the fixed pipeline, the interesting detail is not just that tests pass - it is that the same pipeline structure now flows cleanly into build and deploy.
