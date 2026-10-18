#!/bin/bash
set -euo pipefail
"${PYTHON}" scripts/rebuild_linux_native.py
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
