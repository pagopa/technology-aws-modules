#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"
"$ROOT_DIR/.scripts/generate-idvh-docs.sh"
