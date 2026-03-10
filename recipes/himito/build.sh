#!/bin/bash
set -euo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cargo install --locked --no-track --root "${PREFIX}" --path .
