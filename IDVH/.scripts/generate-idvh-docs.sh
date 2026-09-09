#!/usr/bin/env bash
#
# Purpose: Generate IDVH documentation from catalog YAML files.
# Example:
#   ./IDVH/.scripts/generate-idvh-docs.sh

python3 -m venv .venv
# shellcheck disable=SC1091
. .venv/bin/activate
python3 -m pip install pyyaml==6.0.2
python3 .scripts/generate-idvh-docs.py

deactivate
rm -rf .venv
