# 02 · Compose

This module takes the tiny `goose` service and runs it as a three-container local stack:

- the Go app
- Postgres
- Redis

The app still uses only stdlib. It does not talk SQL yet. It only performs a TCP reachability check to `DB_HOST:DB_PORT` at startup and logs whether Postgres was reachable.

## The Broken Case

`01_broken/docker-compose.yml` starts the app before Postgres is actually ready.

That creates a real startup-order bug:

- the app container starts
- it dials `postgres:5432`
- Postgres is still booting
- the dial fails
- the app keeps running, but the log proves the dependency was not ready

This is a classic interview point: **container start order is not the same as service readiness**.

## The Fix

`02_fixed/docker-compose.yml` adds:

- a Postgres healthcheck using `pg_isready`
- `depends_on` with `condition: service_healthy`

That forces the app to wait until Postgres is actually accepting connections.

## Why This Matters

A lot of "works on my machine" issues happen because local dependencies were started manually in a lucky order. Compose makes that visible quickly.

The lesson carries directly into Kubernetes:

- Compose healthchecks
- Kubernetes readiness probes
- Helm values per environment

Different tools, same operational idea.

## Files

- `01_broken/` shows the startup race.
- `02_fixed/` shows the healthy dependency chain.
- `demo.sh` runs both versions end-to-end.
- `narrative.md` gives you the interview wording.

## Run It

```bash
bash 02-compose/demo.sh
```

## What To Watch For

In the broken run, look for a log line like:

```text
db reachability check failed
```

In the fixed run, look for:

```text
db reachability check succeeded
```

That one log line is the whole lesson.
