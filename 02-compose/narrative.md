# Narrative - Module 02 Compose

## Cheatsheet Connection

This module connects two ideas from the HTML cheatsheet:

> "We had environment inconsistencies between dev and prod causing hard-to-reproduce bugs."

and

> "Service was getting traffic before it was ready - still warming up its DB connection pool."

Compose is the local version of that same operational problem.

## The Story To Tell

> "I ran the same Go service with Postgres and Redis under Docker Compose. In the broken version, `depends_on` only controlled container start order, so the app tried to dial Postgres before it was healthy and logged a startup failure. In the fixed version I added a Postgres healthcheck plus `condition: service_healthy`, so the app only started once the dependency was actually ready. The key lesson is that start order is not readiness."

## Interview Follow-Up

If someone asks why this matters, the short answer is:

- Compose healthchecks teach the same lesson as Kubernetes readiness probes.
- Local startup races are cheaper to debug than production rollout failures.
- The app should log dependency reachability issues, but it should not crash unless the dependency is truly required to serve traffic.
