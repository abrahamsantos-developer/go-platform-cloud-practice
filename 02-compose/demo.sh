#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
BROKEN_FILE="$ROOT_DIR/02-compose/01_broken/docker-compose.yml"
FIXED_FILE="$ROOT_DIR/02-compose/02_fixed/docker-compose.yml"

cleanup() {
  docker compose -p goose-compose-broken -f "$BROKEN_FILE" down -v --remove-orphans >/dev/null 2>&1 || true
  docker compose -p goose-compose-fixed -f "$FIXED_FILE" down -v --remove-orphans >/dev/null 2>&1 || true
}

trap cleanup EXIT
cleanup

printf '\n[02-compose] Broken stack: app starts before Postgres is healthy.\n'
docker compose -p goose-compose-broken -f "$BROKEN_FILE" up -d --build
sleep 7
printf '\n[02-compose] Broken app logs:\n'
docker compose -p goose-compose-broken -f "$BROKEN_FILE" logs app

if docker compose -p goose-compose-broken -f "$BROKEN_FILE" logs app | grep -q 'db reachability check failed'; then
  printf '\n[02-compose] Confirmed: the app dialed Postgres too early.\n'
else
  printf '\n[02-compose] Expected broken log was not found.\n' >&2
  exit 1
fi

printf '\n[02-compose] Broken health endpoint still answers because the service degrades gracefully:\n'
curl --fail --silent http://127.0.0.1:18080/healthz
printf '\n'

docker compose -p goose-compose-broken -f "$BROKEN_FILE" down -v --remove-orphans >/dev/null

printf '\n[02-compose] Fixed stack: Postgres gets a healthcheck and the app waits for it.\n'
docker compose -p goose-compose-fixed -f "$FIXED_FILE" up -d --build
sleep 8
printf '\n[02-compose] Fixed app logs:\n'
docker compose -p goose-compose-fixed -f "$FIXED_FILE" logs app

if docker compose -p goose-compose-fixed -f "$FIXED_FILE" logs app | grep -q 'db reachability check succeeded'; then
  printf '\n[02-compose] Confirmed: the app started only after Postgres was reachable.\n'
else
  printf '\n[02-compose] Expected fixed log was not found.\n' >&2
  exit 1
fi

printf '\n[02-compose] Fixed health endpoint:\n'
curl --fail --silent http://127.0.0.1:28080/healthz
printf '\n\n[02-compose] Demo complete.\n'
