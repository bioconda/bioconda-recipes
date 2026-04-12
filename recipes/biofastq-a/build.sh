#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=false
export CARGO_HOME="${SRC_DIR}/.cargo-home"

cargo build --release

install -Dm755 "${SRC_DIR}/target/release/biofastq-a" "${PREFIX}/bin/biofastq-a"

