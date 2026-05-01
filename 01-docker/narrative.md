# Narrative - Module 01 Docker

Phrases from the HTML cheatsheet, connected to what you actually did in this module.

## The Cheatsheet Line

> "We had environment inconsistencies between dev and prod causing hard-to-reproduce bugs. I containerized our Go services using multi-stage builds — full Go toolchain in the build stage, minimal scratch/alpine image in the final stage. Cut image size from ~800MB to ~20MB and eliminated 'works on my machine' entirely."

## Your Version, Based On What You Ran

> "For a small Go HTTP service with `/healthz` and `/count`, I built three Dockerfile variants and measured them side by side:
>
> - **Naive**: `golang:bookworm` with the full toolchain in the final image -> about 1 GB.
> - **Multi-stage**: `golang:alpine` as builder plus `scratch` for runtime, statically linked binary with `CGO_ENABLED=0`, symbols stripped with `-ldflags='-s -w'` -> about 10 MB.
> - **Multi-stage + `.dockerignore`**: same runtime image, but with a filtered repo-root build context so rebuilds stay noticeably faster.
>
> The `COPY` order matters too: `go.mod` before the rest of the source keeps `go mod download` cached while dependencies do not change, which makes local iteration much faster."

## Classic Interview Follow-Ups

**Q: Why `scratch` instead of `alpine`?**

R: `scratch` is a zero-byte base image. Alpine adds a few MB and gives you `sh`, `apk`, and `ca-certificates`. For a simple Go binary with no outbound TLS calls and no need for shell access, `scratch` is the cleanest option. If the service needs CA certs for HTTPS, Alpine or distroless becomes the better runtime choice.

**Q: What does `CGO_ENABLED=0` do?**

R: It disables the C toolchain integration. Without that flag, the binary may depend on `libc`. `scratch` does not ship a dynamic linker, so the container fails at startup with a confusing "no such file or directory" error. With `CGO_ENABLED=0`, the binary is fully static and runs cleanly in `scratch`.

**Q: Why `-ldflags="-s -w"`?**

R: `-s` strips the symbol table and `-w` removes DWARF debug info. That usually trims a meaningful chunk off the binary size without changing runtime behavior. The tradeoff is less post-mortem debug information.

**Q: What can still go wrong with multi-stage builds?**

R: The classic mistake is copying only the binary into the final image and forgetting runtime assets such as templates, SQL migrations, or certificates. The container starts, but the app fails later when it looks for files that are no longer present. For Go services, `embed.FS` is often the cleanest fix.
