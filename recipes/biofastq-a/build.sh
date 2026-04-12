#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=false
export CARGO_HOME="${SRC_DIR}/.cargo-home"

cargo install --path . --root "${PREFIX}"
