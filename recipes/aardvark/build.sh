#!/usr/bin/env bash

# following recommendations of https://bioconda.github.io/contributor/guidelines.html#rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .
