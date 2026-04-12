#!/bin/bash
set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=false
export CARGO_HOME="${SRC_DIR}/.cargo-home"

cargo build --release --locked

install -Dm755 "target/release/biofastq-a" "${PREFIX}/bin/biofastq-a"
