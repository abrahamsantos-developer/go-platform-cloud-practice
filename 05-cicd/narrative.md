# Narrative - Module 05 CI/CD

## Cheatsheet Quote

> "Our GitLab pipeline had four stages: lint -> test -> build -> deploy. On every MR it ran `golangci-lint` and the full test suite including `-race`."

## The Story To Tell

> "I built a local GitLab-style pipeline with lint, test, build, and deploy stages. In the broken version, the race detector failed the test stage, so the pipeline never reached build or deploy. In the fixed version, I removed the race, built the Docker image, and rendered the Helm deployment using the commit-style image tag. The main point is that CI should stop unsafe code early and carry the same artifact into deployment."

## Interview Follow-Up

If someone asks why `-race` matters, the short answer is:

- some concurrency bugs do not fail functionally every run
- the race detector catches memory safety issues before production does
- a reliable pipeline is not just automation, it is an enforcement mechanism
