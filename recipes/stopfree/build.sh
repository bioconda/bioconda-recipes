#!/bin/bash
set -euxo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
