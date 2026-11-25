#!/usr/bin/env bash
set -euo pipefail

export FOCALOOP_PORTABLE_ISA=1
make install-native PREFIX="${PREFIX}" PYTHON="${PYTHON}"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
