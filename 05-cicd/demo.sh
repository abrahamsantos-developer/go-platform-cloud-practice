#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

printf '[05-cicd] Broken pipeline: expect the test stage to fail under -race.\n'
if "$ROOT_DIR/05-cicd/01_broken/run-locally.sh"; then
  printf '[05-cicd] Broken pipeline unexpectedly passed.\n' >&2
  exit 1
else
  printf '\n[05-cicd] Confirmed: the broken pipeline stopped before build/deploy.\n'
fi

printf '\n[05-cicd] Fixed pipeline: the same stages should now pass cleanly.\n'
"$ROOT_DIR/05-cicd/02_fixed/run-locally.sh"

printf '\n[05-cicd] Demo complete.\n'
