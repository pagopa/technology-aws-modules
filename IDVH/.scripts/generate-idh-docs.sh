#!/usr/bin/env bash
#
# Purpose: Generate IDH documentation from catalog YAML files.
# Example:
#   ./IDVH/.scripts/generate-idh-docs.sh

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
python3 -m pip install pyyaml==6.0.2
python3 .scripts/idh_doc_gen.py
deactivate
rm -rf .venv
