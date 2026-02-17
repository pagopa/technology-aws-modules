#!/bin/bash

set -euo pipefail

ACTION="${1:-}"
if [ -z "$ACTION" ]; then
  echo "Usage: $0 {init|plan|apply|destroy|clean} [terraform_options...]"
  exit 1
fi
shift

TF_ARGS=("$@")

terraform_init() {
  local init_args=("$@")
  if [ -f "./backend.hcl" ]; then
    terraform init -backend-config=backend.hcl "${init_args[@]}"
  else
    terraform init "${init_args[@]}"
  fi
}

terraform_exec() {
  terraform_init
  terraform "$ACTION" "${TF_ARGS[@]}"
}

case "$ACTION" in
  init)
    terraform_init "${TF_ARGS[@]}"
    ;;
  plan|apply|destroy)
    terraform_exec
    ;;
  clean)
    rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
    ;;
  *)
    echo "Usage: $0 {init|plan|apply|destroy|clean} [terraform_options...]"
    exit 1
    ;;
esac
