#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
BROKEN_DIR="$ROOT_DIR/06-terraform/01_broken"
BOOTSTRAP_DIR="$ROOT_DIR/06-terraform/02_fixed/bootstrap"
STACK_DIR="$ROOT_DIR/06-terraform/02_fixed/stack"
LOCALSTACK_IMAGE="localstack/localstack:4.14.0"
LOCALSTACK_CONTAINER="goose-localstack"

cleanup() {
  docker rm -f "$LOCALSTACK_CONTAINER" >/dev/null 2>&1 || true
}

trap cleanup EXIT
cleanup

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_REGION=us-east-1

printf '[06-terraform] Pulling LocalStack once before timing the demo.\n'
docker pull "$LOCALSTACK_IMAGE" >/dev/null

printf '[06-terraform] Starting LocalStack.\n'
docker run -d --rm --name "$LOCALSTACK_CONTAINER" -p 4566:4566 -e SERVICES=s3,dynamodb "$LOCALSTACK_IMAGE" >/dev/null
for _ in {1..30}; do
  if curl --silent http://127.0.0.1:4566/_localstack/health >/tmp/goose-localstack-health.json && grep -q '"s3": "available"' /tmp/goose-localstack-health.json; then
    break
  fi
  sleep 2
done
if ! grep -q '"dynamodb": "available"' /tmp/goose-localstack-health.json; then
  printf '[06-terraform] LocalStack did not become healthy in time.\n' >&2
  exit 1
fi

rm -rf "$BROKEN_DIR/.terraform" "$BROKEN_DIR/.terraform.lock.hcl" "$BROKEN_DIR/terraform.tfstate" "$BROKEN_DIR/terraform.tfstate.backup"
rm -rf "$BOOTSTRAP_DIR/.terraform" "$BOOTSTRAP_DIR/.terraform.lock.hcl" "$BOOTSTRAP_DIR/terraform.tfstate" "$BOOTSTRAP_DIR/terraform.tfstate.backup"
rm -rf "$STACK_DIR/.terraform" "$STACK_DIR/.terraform.lock.hcl"

printf '\n[06-terraform] Broken version: local state plus no shared lock.\n'
terraform -chdir="$BROKEN_DIR" init >/tmp/goose-tf-broken-init.log
terraform -chdir="$BROKEN_DIR" apply -auto-approve -lock=false -var='hold_duration=12s' >/tmp/goose-tf-broken-1.log 2>&1 &
BROKEN_PID_1=$!
sleep 2
terraform -chdir="$BROKEN_DIR" apply -auto-approve -lock=false -var='hold_duration=12s' >/tmp/goose-tf-broken-2.log 2>&1 &
BROKEN_PID_2=$!
sleep 3
if kill -0 "$BROKEN_PID_1" >/dev/null 2>&1 && kill -0 "$BROKEN_PID_2" >/dev/null 2>&1; then
  printf '[06-terraform] Confirmed: both broken applies were allowed to run at the same time.\n'
else
  printf '[06-terraform] Broken applies did not overlap as expected.\n' >&2
  exit 1
fi
wait "$BROKEN_PID_1" || true
wait "$BROKEN_PID_2" || true
printf '\n[06-terraform] Broken apply excerpts:\n'
sed -n '1,40p' /tmp/goose-tf-broken-1.log
sed -n '1,40p' /tmp/goose-tf-broken-2.log

printf '\n[06-terraform] Fixed version: bootstrap remote backend resources first.\n'
terraform -chdir="$BOOTSTRAP_DIR" init >/tmp/goose-tf-bootstrap-init.log
terraform -chdir="$BOOTSTRAP_DIR" apply -auto-approve >/tmp/goose-tf-bootstrap-apply.log
terraform -chdir="$STACK_DIR" init -reconfigure -backend-config="$STACK_DIR/backend.hcl" >/tmp/goose-tf-stack-init.log
terraform -chdir="$STACK_DIR" apply -auto-approve -var='hold_duration=12s' >/tmp/goose-tf-fixed-1.log 2>&1 &
FIXED_PID_1=$!
sleep 2
if terraform -chdir="$STACK_DIR" apply -auto-approve -lock-timeout=3s -var='hold_duration=12s' >/tmp/goose-tf-fixed-2.log 2>&1; then
  printf '[06-terraform] Fixed second apply unexpectedly succeeded.\n' >&2
  exit 1
fi
if grep -q 'Error acquiring the state lock' /tmp/goose-tf-fixed-2.log; then
  printf '[06-terraform] Confirmed: remote state locking blocked the second apply.\n'
else
  printf '[06-terraform] Expected lock error not found.\n' >&2
  cat /tmp/goose-tf-fixed-2.log >&2
  exit 1
fi
wait "$FIXED_PID_1"

printf '\n[06-terraform] Fixed apply excerpt:\n'
sed -n '1,40p' /tmp/goose-tf-fixed-2.log
printf '\n[06-terraform] Remote state objects:\n'
terraform -chdir="$STACK_DIR" state list

printf '\n[06-terraform] Demo complete.\n'
