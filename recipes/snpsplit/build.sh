#!/bin/bash
set -xeuo pipefail

cargo build --release --locked --manifest-path rust/Cargo.toml

# conda's rust compiler sets CARGO_BUILD_TARGET, so the binary is under target/<triple>/release
BIN="rust/target/${CARGO_BUILD_TARGET:-}/release/snpsplit"
[ -f "$BIN" ] || BIN="rust/target/release/snpsplit"

# Installed as SNPsplit, the other two names linked to it: snpsplit and SNPsplit clash on osx
install -d "${PREFIX}/bin"
install -m 0755 "$BIN" "${PREFIX}/bin/SNPsplit"
cd "${PREFIX}/bin"
ln -s SNPsplit tag2sort
ln -s SNPsplit SNPsplit_genome_preparation
