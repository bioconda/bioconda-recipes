#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# The workspace's default members are the command-line tools (msascope, a GUI, is left out).
export CARGO_PROFILE_RELEASE_LTO=thin
cargo build --release --locked

# conda's Rust sets CARGO_BUILD_TARGET, so binaries go to target/<triple>/release.
out="target/${CARGO_BUILD_TARGET:+${CARGO_BUILD_TARGET}/}release"
mkdir -p "${PREFIX}/bin"
for b in sheetgen leanqc isotable dblock seqplan cooccur gtdbprep irit-gtdb-prep irit-mcp; do
  install -m 755 "${out}/${b}" "${PREFIX}/bin/${b}"
done
