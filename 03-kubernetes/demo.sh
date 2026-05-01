#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
BROKEN_PENDING="$ROOT_DIR/03-kubernetes/01_broken/01_pending.yaml"
BROKEN_READINESS="$ROOT_DIR/03-kubernetes/01_broken/02_bad_readiness.yaml"
FIXED_DEPLOYMENT="$ROOT_DIR/03-kubernetes/02_fixed/deployment.yaml"
FIXED_SERVICE="$ROOT_DIR/03-kubernetes/02_fixed/service.yaml"
CLUSTER_NAME="goose-k8s"
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
  printf '[03-kubernetes] Building goose:multi because the local image is missing.\n'
  docker build -f "$ROOT_DIR/01-docker/02_multistage/Dockerfile" -t goose:multi "$ROOT_DIR"
fi

printf '[03-kubernetes] Creating kind cluster %s (first run can take ~30s).\n' "$CLUSTER_NAME"
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

printf '\n[03-kubernetes] Broken example A: absurd requests keep the Pod Pending.\n'
kubectl apply -f "$BROKEN_PENDING"
sleep 5
kubectl get pods -n goose
PENDING_POD=$(kubectl get pods -n goose -l app=goose-pending -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$PENDING_POD" -n goose
if kubectl describe pod "$PENDING_POD" -n goose | grep -Eq 'Insufficient|FailedScheduling'; then
  printf '\n[03-kubernetes] Confirmed: scheduler rejected the Pod due to impossible requests.\n'
else
  printf '\n[03-kubernetes] Expected scheduling failure not found.\n' >&2
  exit 1
fi
kubectl delete deployment goose-pending -n goose >/dev/null

printf '\n[03-kubernetes] Broken example B: wrong readiness path keeps the Pod unready.\n'
kubectl apply -f "$BROKEN_READINESS"
sleep 8
kubectl get pods -n goose
READINESS_POD=$(kubectl get pods -n goose -l app=goose-bad-readiness -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$READINESS_POD" -n goose
if kubectl describe pod "$READINESS_POD" -n goose | grep -q 'Readiness probe failed'; then
  printf '\n[03-kubernetes] Confirmed: the container runs, but readiness is broken.\n'
else
  printf '\n[03-kubernetes] Expected readiness failure not found.\n' >&2
  exit 1
fi
kubectl delete -f "$BROKEN_READINESS" >/dev/null

printf '\n[03-kubernetes] Fixed version: realistic resources plus /healthz readiness.\n'
kubectl apply -f "$FIXED_DEPLOYMENT"
kubectl apply -f "$FIXED_SERVICE"
kubectl rollout status deployment/goose -n goose --timeout=60s
kubectl get pods -n goose

kubectl port-forward -n goose service/goose 18081:80 >/tmp/goose-k8s-port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
sleep 3
printf '\n[03-kubernetes] Fixed service health endpoint:\n'
curl --fail --silent http://127.0.0.1:18081/healthz
printf '\n\n[03-kubernetes] Demo complete.\n'
