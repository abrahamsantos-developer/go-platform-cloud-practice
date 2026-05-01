#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
BROKEN_CHART="$ROOT_DIR/04-helm/01_broken/chart"
FIXED_CHART="$ROOT_DIR/04-helm/02_fixed/chart"
CLUSTER_NAME="goose-helm"
NAMESPACE="goose-helm"
PORT_FORWARD_PID=""
KIND_CONFIG_FILE=""

cleanup() {
  if [[ -n "$PORT_FORWARD_PID" ]]; then
    kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$KIND_CONFIG_FILE" ]]; then
    rm -f "$KIND_CONFIG_FILE"
  fi
  kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
}

trap cleanup EXIT
kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true

if ! docker image inspect goose:multi >/dev/null 2>&1; then
  printf '[04-helm] Building goose:multi because the local image is missing.\n'
  docker build -f "$ROOT_DIR/01-docker/02_multistage/Dockerfile" -t goose:multi "$ROOT_DIR"
fi

printf '[04-helm] Creating kind cluster %s (first run can take ~30s).\n' "$CLUSTER_NAME"
KIND_CONFIG_FILE=$(mktemp)
cat <<'EOF' > "$KIND_CONFIG_FILE"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
EOF
kind create cluster --name "$CLUSTER_NAME" --config "$KIND_CONFIG_FILE"
kind load docker-image goose:multi --name "$CLUSTER_NAME"

printf '\n[04-helm] Broken chart: Helm should fail before install because of the template typo.\n'
if helm install goose-broken "$BROKEN_CHART" -n "$NAMESPACE" --create-namespace -f "$BROKEN_CHART/values/dev.yaml" >/tmp/goose-helm-broken.log 2>&1; then
  printf '[04-helm] Broken chart unexpectedly installed.\n' >&2
  cat /tmp/goose-helm-broken.log >&2
  exit 1
fi
cat /tmp/goose-helm-broken.log

printf '\n[04-helm] Fixed chart: install with dev values.\n'
helm install goose "$FIXED_CHART" -n "$NAMESPACE" --create-namespace -f "$FIXED_CHART/values/dev.yaml"
kubectl rollout status deployment/goose -n "$NAMESPACE" --timeout=60s
DEV_REPLICAS=$(kubectl get deploy goose -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
printf '[04-helm] Dev replicas: %s\n' "$DEV_REPLICAS"

kubectl port-forward -n "$NAMESPACE" service/goose 18082:80 >/tmp/goose-helm-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
sleep 3
printf '\n[04-helm] Dev health endpoint:\n'
curl --fail --silent http://127.0.0.1:18082/healthz
printf '\n'
kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
PORT_FORWARD_PID=""

printf '\n[04-helm] Upgrade the same release to prod values.\n'
helm upgrade goose "$FIXED_CHART" -n "$NAMESPACE" -f "$FIXED_CHART/values/prod.yaml"
kubectl rollout status deployment/goose -n "$NAMESPACE" --timeout=60s
PROD_REPLICAS=$(kubectl get deploy goose -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
printf '[04-helm] Prod replicas after upgrade: %s\n' "$PROD_REPLICAS"

printf '\n[04-helm] Release history:\n'
helm history goose -n "$NAMESPACE"

printf '\n[04-helm] Roll back to revision 1.\n'
helm rollback goose 1 -n "$NAMESPACE"
kubectl rollout status deployment/goose -n "$NAMESPACE" --timeout=60s
ROLLED_BACK_REPLICAS=$(kubectl get deploy goose -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
printf '[04-helm] Replicas after rollback: %s\n' "$ROLLED_BACK_REPLICAS"

if [[ "$DEV_REPLICAS" != "1" || "$PROD_REPLICAS" != "3" || "$ROLLED_BACK_REPLICAS" != "1" ]]; then
  printf '[04-helm] Replica checks failed.\n' >&2
  exit 1
fi

printf '\n[04-helm] Demo complete.\n'
