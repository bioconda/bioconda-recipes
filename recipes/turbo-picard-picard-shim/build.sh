#!/usr/bin/env bash
set -euo pipefail

export OPENSSL_NO_VENDOR=1
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path crates/turbo-picard-cli \
  --bin picard
