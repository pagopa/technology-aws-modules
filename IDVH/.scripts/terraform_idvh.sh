#!/usr/bin/env bash

set -euo pipefail

log_info() { echo "ℹ️  [IDVH] $*"; }
log_step() { echo "🔹 [IDVH] $*"; }
log_warn() { echo "⚠️  [IDVH] $*"; }
log_ok() { echo "✅ [IDVH] $*"; }

usage() {
  cat <<'EOF'
Usage: terraform_idvh.sh [options]

Run the standard IDVH Terraform checks for a module:
1) terraform init -backend=false
2) terraform validate
3) terraform test (through tests/terraform.sh when available)

Options:
  --module-dir <path>  Module directory (default: current directory).
  --skip-init          Skip terraform init.
  --skip-tests         Skip terraform tests.
  -h, --help           Show this help.
EOF
}

MODULE_DIR="$(pwd -P)"
SKIP_INIT=0
SKIP_TESTS=0

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
    --skip-init)
      SKIP_INIT=1
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "❌ [IDVH] Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

MODULE_DIR="$(cd "$MODULE_DIR" && pwd -P)"

FIRST_TF_FILE="$(find "$MODULE_DIR" -maxdepth 1 -type f -name '*.tf' -print -quit)"
if [ -z "$FIRST_TF_FILE" ]; then
  echo "❌ [IDVH] No Terraform files (*.tf) found in: $MODULE_DIR" >&2
  exit 1
fi

log_info "Module: $MODULE_DIR"
cd "$MODULE_DIR"

if [ "$SKIP_INIT" -eq 0 ]; then
  log_step "[1/3] Terraform init"
  log_info "Command: terraform init -backend=false -no-color"
  terraform init -backend=false -no-color
  log_info "Init completed"
fi

log_step "[2/3] Terraform validate"
log_info "Command: terraform validate -no-color"
terraform validate -no-color
log_info "Validate completed"

if [ "$SKIP_TESTS" -eq 1 ]; then
  log_warn "Tests skipped (--skip-tests)"
  log_ok "Module checks completed"
  exit 0
fi

TEST_RUNNER="$MODULE_DIR/tests/terraform.sh"
if [ -x "$TEST_RUNNER" ]; then
  log_step "[3/3] Running tests through tests/terraform.sh"
  "$TEST_RUNNER" --module-dir "$MODULE_DIR" --skip-init
  log_ok "Module checks completed"
  exit 0
fi

if compgen -G "$MODULE_DIR/tests/*.tftest.hcl" > /dev/null; then
  log_step "[3/3] Running Terraform tests directly"
  log_info "Command: terraform test -test-directory=tests -no-color"
  terraform test -test-directory=tests -no-color
  log_ok "Module checks completed"
  exit 0
fi

log_warn "No Terraform tests found in $MODULE_DIR/tests, skipping tests"
log_ok "Module checks completed"
