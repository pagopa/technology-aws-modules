#!/usr/bin/env bash

set -euo pipefail

log_info() { echo "ℹ️  [IDVH] $*"; }
log_step() { echo "🔹 [IDVH] $*"; }
log_warn() { echo "⚠️  [IDVH] $*"; }
log_ok() { echo "✅ [IDVH] $*"; }

usage() {
  cat <<'EOF'
Usage: terraform_idvh_test.sh [options]

Run Terraform tests for an IDVH module.
Designed to be symlinked in a module test directory (for example: ./tests).

Options:
  --module-dir <path>  Module directory (default: current directory).
  --test-dir <name>    Test directory name relative to module root (default: tests).
  --filter <value>     Pass a terraform test filter (can be repeated).
  --skip-init          Skip terraform init.
  --color              Keep Terraform color output.
  -h, --help           Show this help.
EOF
}

CURRENT_DIR="$(pwd -P)"
MODULE_DIR="$CURRENT_DIR"
TEST_DIR_NAME="tests"
SKIP_INIT=0
NO_COLOR=1
FILTERS=()
EXTRA_ARGS=()

if find "$CURRENT_DIR" -maxdepth 1 -type f -name '*.tftest.hcl' -print -quit | grep -q .; then
  MODULE_DIR="$(cd "$CURRENT_DIR/.." && pwd -P)"
  TEST_DIR_NAME="$(basename "$CURRENT_DIR")"
fi

while (($#)); do
  case "$1" in
    --module-dir)
      if [ $# -lt 2 ]; then
        echo "❌ [IDVH] Missing value for --module-dir" >&2
        exit 1
      fi
      MODULE_DIR="$2"
      shift 2
      ;;
    --test-dir)
      if [ $# -lt 2 ]; then
        echo "❌ [IDVH] Missing value for --test-dir" >&2
        exit 1
      fi
      TEST_DIR_NAME="$2"
      shift 2
      ;;
    --filter)
      if [ $# -lt 2 ]; then
        echo "❌ [IDVH] Missing value for --filter" >&2
        exit 1
      fi
      FILTERS+=("$2")
      shift 2
      ;;
    --skip-init)
      SKIP_INIT=1
      shift
      ;;
    --color)
      NO_COLOR=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      EXTRA_ARGS+=("$@")
      break
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

MODULE_DIR="$(cd "$MODULE_DIR" && pwd -P)"

if [ "${TEST_DIR_NAME#/}" != "$TEST_DIR_NAME" ]; then
  TEST_DIR_PATH="$TEST_DIR_NAME"
else
  TEST_DIR_PATH="$MODULE_DIR/$TEST_DIR_NAME"
fi

if [ ! -d "$TEST_DIR_PATH" ]; then
  log_warn "Test directory not found: $TEST_DIR_PATH, skipping tests"
  exit 0
fi

FIRST_TEST_FILE="$(find "$TEST_DIR_PATH" -type f -name '*.tftest.hcl' -print -quit)"
if [ -z "$FIRST_TEST_FILE" ]; then
  log_warn "No .tftest.hcl file found in $TEST_DIR_PATH, skipping tests"
  exit 0
fi

log_info "Test module: $MODULE_DIR"
log_info "Test directory: $TEST_DIR_PATH"

cd "$MODULE_DIR"

if [ "$SKIP_INIT" -eq 0 ]; then
  log_step "[1/2] Terraform init for tests"
  log_info "Command: terraform init -backend=false -no-color"
  terraform init -backend=false -no-color
  log_info "Test init completed"
fi

TEST_CMD=(terraform test "-test-directory=$TEST_DIR_NAME")

if [ "$NO_COLOR" -eq 1 ]; then
  TEST_CMD+=("-no-color")
fi

for filter in "${FILTERS[@]-}"; do
  [ -n "$filter" ] || continue
  TEST_CMD+=("-filter=$filter")
done

for extra_arg in "${EXTRA_ARGS[@]-}"; do
  [ -n "$extra_arg" ] || continue
  TEST_CMD+=("$extra_arg")
done

log_step "[2/2] Running Terraform tests"
log_info "Command: ${TEST_CMD[*]}"
"${TEST_CMD[@]}"
log_ok "Tests completed"
