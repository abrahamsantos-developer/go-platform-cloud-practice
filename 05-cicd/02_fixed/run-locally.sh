#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
FIXTURE_DIR="$ROOT_DIR/05-cicd/02_fixed/fixture"
IMAGE_TAG="ci-fixed-local"

cleanup() {
  docker image rm "goose:$IMAGE_TAG" >/dev/null 2>&1 || true
}

trap cleanup EXIT

printf '[05-cicd fixed] Stage: lint\n'
(
  cd "$FIXTURE_DIR"
  golangci-lint run ./...
)

printf '\n[05-cicd fixed] Stage: test (-race)\n'
(
  cd "$FIXTURE_DIR"
  go test -race ./...
)

printf '\n[05-cicd fixed] Stage: build\n'
docker build -f "$ROOT_DIR/01-docker/02_multistage/Dockerfile" -t "goose:$IMAGE_TAG" "$ROOT_DIR"

printf '\n[05-cicd fixed] Stage: deploy (render Helm chart with the local image tag)\n'
helm template goose "$ROOT_DIR/04-helm/02_fixed/chart" -f "$ROOT_DIR/04-helm/02_fixed/chart/values/staging.yaml" --set image.tag="$IMAGE_TAG" >/tmp/goose-cicd-fixed-rendered.yaml
grep -n "image:" /tmp/goose-cicd-fixed-rendered.yaml
