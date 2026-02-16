#!/usr/bin/env bash

set -euo pipefail

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
        echo "Missing value for --module-dir" >&2
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
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

MODULE_DIR="$(cd "$MODULE_DIR" && pwd -P)"

FIRST_TF_FILE="$(find "$MODULE_DIR" -maxdepth 1 -type f -name '*.tf' -print -quit)"
if [ -z "$FIRST_TF_FILE" ]; then
  echo "❌ Nessun file Terraform (*.tf) trovato in: $MODULE_DIR" >&2
  exit 1
fi

echo "📦 Modulo: $MODULE_DIR"
cd "$MODULE_DIR"

if [ "$SKIP_INIT" -eq 0 ]; then
  echo "🚀 [1/3] Terraform init"
  echo "   terraform init -backend=false -no-color"
  terraform init -backend=false -no-color
  echo "✅ Init completato"
fi

echo "🔎 [2/3] Terraform validate"
echo "   terraform validate -no-color"
terraform validate -no-color
echo "✅ Validate completato"

if [ "$SKIP_TESTS" -eq 1 ]; then
  echo "⏭️  Test saltati (--skip-tests)"
  echo "✅ Check modulo completati"
  exit 0
fi

TEST_RUNNER="$MODULE_DIR/tests/terraform.sh"
if [ -x "$TEST_RUNNER" ]; then
  echo "🧪 [3/3] Test tramite tests/terraform.sh"
  "$TEST_RUNNER" --module-dir "$MODULE_DIR" --skip-init
  echo "✅ Check modulo completati"
  exit 0
fi

if compgen -G "$MODULE_DIR/tests/*.tftest.hcl" > /dev/null; then
  echo "🧪 [3/3] Terraform test diretto"
  echo "   terraform test -test-directory=tests -no-color"
  terraform test -test-directory=tests -no-color
  echo "✅ Check modulo completati"
  exit 0
fi

echo "⚠️  Nessun test Terraform trovato in $MODULE_DIR/tests, skip test"
echo "✅ Check modulo completati"
