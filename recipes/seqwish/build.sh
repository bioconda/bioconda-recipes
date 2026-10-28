#!/bin/bash

set -xe

# seqwish 0.7.12+ is a Rust program. The repo pins target-cpu=native via
# .cargo/config.toml, which would make the package crash on machines with a
# different CPU. Remove it so a portable baseline target is used.
rm -f .cargo/config.toml .cargo/config

# Bundle third-party crate licenses (bioconda Rust guideline).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --root "${PREFIX}" --path .
