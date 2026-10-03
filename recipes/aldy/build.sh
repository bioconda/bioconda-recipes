#!/usr/bin/env bash
set -euo pipefail

$PYTHON -m pip install . \
    --no-deps \
    --no-build-isolation \
    -vv
