# Narrative - Module 04 Helm

## Cheatsheet Quote

> "Our GitLab pipeline built the Docker image, pushed it to the registry, then ran `helm upgrade --install` with the environment-specific values file. If a deploy went bad, `helm rollback` got us back in under a minute."

## The Story To Tell

> "I wrapped the service manifests in a Helm chart with `dev`, `staging`, and `prod` values files. First I broke the chart on purpose with a template typo to show that Helm failures can happen before Kubernetes even receives a valid manifest. Then I installed the fixed chart with dev values, upgraded the same release to prod values, checked release history, and rolled back to the previous revision. The value of Helm is release management plus environment-specific config without copying manifests."

## Why Interviewers Like This Example

It proves you understand:

- the difference between templating errors and runtime errors
- how to manage one chart across multiple environments
- how `helm rollback` changes the conversation from panic to routine recovery
