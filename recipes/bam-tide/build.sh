#!/usr/bin/env bash
set -euo pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo build --release --locked

install -Dm755 target/release/bam-coverage "${PREFIX}/bin/bam-coverage"
install -Dm755 target/release/bam-subset-tag "${PREFIX}/bin/bam-subset-tag"

