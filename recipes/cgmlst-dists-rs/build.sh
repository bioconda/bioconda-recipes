#!/bin/bash
set -ex

# Portable build: no -C target-cpu=native in a package (it would crash on older CPUs)
cargo install --no-track --locked --root "$PREFIX" --path .
# Named cgmlst-dists-rs in the package, so it does not clash with the original
# cgmlst-dists (tseemann) when both are installed in one environment.
mv "$PREFIX/bin/cgmlst-dists" "$PREFIX/bin/cgmlst-dists-rs"

# Bundle third-party licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
