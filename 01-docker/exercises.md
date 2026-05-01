# Exercises - Module 01

> Assume you are standing in the repo root.

## 1. Measure the `01_naive` Disaster

```bash
docker build -f 01-docker/01_naive/Dockerfile -t goose:naive .
docker images goose:naive
```

Write down:
- Image size: _________ MB
- First build time: _________ s

Change one trivial line in `service/main.go` (for example add a `// hello`) and rebuild:

```bash
docker build -f 01-docker/01_naive/Dockerfile -t goose:naive .
```

Write down the second build time. Did Docker cache anything? How many layers were reused?

## 2. Compare With `02_multistage`

```bash
docker build -f 01-docker/02_multistage/Dockerfile -t goose:multi .
docker images goose:multi
```

Compare it with `01_naive`:
- Naive size: _____ vs Multi size: _____ -> how many times smaller?
- Change another line in `main.go` and rebuild the multi-stage image. What is the second build time?

## 3. Break the Cache by Reversing the Order

Edit `02_multistage/Dockerfile` and move `COPY service/ ./` **before** `COPY service/go.mod`:

```dockerfile
COPY service/ ./
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build ...
```

Build it, change one line in `main.go`, then rebuild. How long does it take? Compare it with the correct version. That is the difference between a cache miss and a cache hit.

## 4. Break `.dockerignore`

Move it temporarily to see the impact:

```bash
mv .dockerignore .dockerignore.disabled

# Build with the unfiltered context
docker build -f 01-docker/03_dockerignore/Dockerfile -t goose:noignore .

# Look at the build output. The first lines say something like:
#   "transferring context: X MB"
# Write down the value.

# Restore it
mv .dockerignore.disabled .dockerignore
docker build -f 01-docker/03_dockerignore/Dockerfile -t goose:withignore .
# Compare the "transferring context" size.
```

> Tip: if your repo is clean, the difference will be small. To see the **real** effect, create a throwaway file:
>
> ```bash
> dd if=/dev/urandom of=garbage.bin bs=1M count=50
> ```
>
> Repeat the experiment, then delete it with `rm garbage.bin`.

## 5. Inspect Layers

```bash
docker history goose:multi
docker history goose:naive
```

How many layers does each image have? Which layer is the heaviest in each one?

## 6. Run The Binary And Verify

```bash
docker run --rm -d -p 8080:8080 --name goose-test goose:multi
sleep 1
curl -s http://localhost:8080/healthz
curl -s -X POST http://localhost:8080/count
curl -s -X POST http://localhost:8080/count
curl -s http://localhost:8080/count

docker stop goose-test
```

Does it match what you tested in the concurrency repo? It should be identical. That is the point of the container.

## 7. Bonus: `scratch` vs `alpine` vs distroless

Try a variant with `FROM alpine:3.20` instead of `scratch`:

```dockerfile
FROM alpine:3.20
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

How much extra size does Alpine add? Is it worth it? Hint: Alpine gives you `sh` and `ca-certificates`, which matter if your app makes outbound HTTPS calls. `scratch` does not.

## 8. What Happens If I Remove `CGO_ENABLED=0`?

Edit `02_multistage/Dockerfile` and remove the flag. Build it. Does it still work? Try to run it:

```bash
docker run --rm goose:multi
```

What error do you see? Spoiler: the binary cannot find `libc` inside `scratch`.

## 9. Cleanup

```bash
docker rmi goose:naive goose:multi goose:dockerignore goose:noignore goose:withignore 2>/dev/null
docker image prune -f
```
