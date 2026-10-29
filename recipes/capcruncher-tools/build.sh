#!/usr/bin/env bash
set -euxo pipefail

export PYO3_PYTHON="${PYTHON}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation