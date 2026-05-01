# 01 · Docker

> Cheatsheet: the **"Docker"** section from the HTML.
>
> *"We had environment inconsistencies between dev and prod causing hard-to-reproduce bugs. I containerized our Go services using multi-stage builds — full Go toolchain in the build stage, minimal scratch/alpine image in the final stage. Cut image size from ~800MB to ~20MB and eliminated 'works on my machine' entirely."*

## The Service We Package

`service/main.go` in the sibling directory. Pure stdlib: `/healthz` + `/count`. Zero dependencies. The complexity in this module comes from the Dockerfiles, not the Go code.

## Why It Matters

A badly built image is:
- Slow and expensive: every cluster node pulls hundreds of MB.
- Wider attack surface: the final runtime image still ships the Go toolchain and packages it does not need.
- Slow to iterate on: small code changes can invalidate most of the build cache.

A well-built image is:
- Around 10MB.
- Fast to rebuild when only application code changes.
- Minimal at runtime: just the statically linked binary.

## Exercises In Order

| # | Folder | Expected size | What it shows |
|---|--------|---------------|---------------|
| 01 | [`01_naive/`](./01_naive/) | ~1.0 GB | What you do not want: build and runtime in the same image. |
| 02 | [`02_multistage/`](./02_multistage/) | ~10 MB | Multi-stage + `scratch`, the default pattern you should reach for. |
| 03 | [`03_dockerignore/`](./03_dockerignore/) | ~10 MB | Same as 02, but with a repo-root `.dockerignore`. |

## Important: The Build Context

Docker does **not** allow `COPY ../../foo` in a Dockerfile. You cannot copy files from outside the **build context** you pass to `docker build`. That is why every build in this repo runs from the repo root and points at the Dockerfile with `-f`.

```bash
# Build context = repo root (the trailing `.`)
# Pick the Dockerfile with `-f`
docker build -f 01-docker/02_multistage/Dockerfile -t goose:multi .
```

## The 3 Key Ideas

### 1. Multi-stage build

Use one image such as `golang:1.26-alpine` to compile, then a second image such as `scratch` to run. Only the final stage ships in the resulting image.

```dockerfile
FROM golang:1.26-alpine AS builder
# ... compila ...

FROM scratch
COPY --from=builder /app/server /server
ENTRYPOINT ["/server"]
```

### 2. `CGO_ENABLED=0`

With CGO disabled, the binary does not depend on `libc`. That is why it can run in `scratch`, which has nothing in it. If CGO stays enabled, the binary fails at runtime because it expects shared libraries that `scratch` does not provide.

### 3. Layer caching

Docker caches by layer. If you copy `go.mod` / `go.sum` before the rest of the source, code changes do not invalidate the `go mod download` layer. That keeps rebuilds much faster.

```dockerfile
COPY service/go.mod ./        # <- cached while deps stay the same
RUN go mod download           # <- cached
COPY service/ ./              # <- this is the layer code changes invalidate
RUN go build ...
```

## How To Run The 3 Exercises

> Assume `pwd` is the repo root (`go-platform-cloud-practice/`).

```bash
# Build the 3 versions
docker build -f 01-docker/01_naive/Dockerfile        -t goose:naive .
docker build -f 01-docker/02_multistage/Dockerfile   -t goose:multi .
docker build -f 01-docker/03_dockerignore/Dockerfile -t goose:dockerignore .

# Compare sizes
docker images | grep goose
# REPOSITORY   TAG               SIZE
# goose        naive             ~1.0GB
# goose        multi             ~10MB
# goose        dockerignore      ~10MB

# Run one of them
docker run --rm -p 8080:8080 goose:multi
# in another terminal:
curl http://localhost:8080/healthz
curl -X POST http://localhost:8080/count
```

## The `.dockerignore` Lives At Repo Root

It lives at `/.dockerignore` in the repo root. It applies to every build that uses the repo as its context. Inspect it with:

```bash
cat .dockerignore
```

To see its impact, do exercise 4 in [`exercises.md`](./exercises.md): rename it temporarily, rebuild, and compare the reported context size.

## Interview Narrative

After doing the three exercises, you can say this almost word for word:

> "I containerized a Go service with multi-stage builds. The build stage uses `golang:alpine` to compile, and the final image is `scratch` with only the statically linked binary (`CGO_ENABLED=0`). We cut image size from roughly 1GB to roughly 10MB. The `.dockerignore` and the order of the `COPY` instructions make incremental rebuilds fast because they preserve the `go mod download` cache layer."

That is the same story the cheatsheet points at. The difference is that you actually ran it and measured it.
