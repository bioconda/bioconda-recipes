#!/usr/bin/env bash

# no .git folder, so use a tag indicating conda build
export CUSTOM_VERGEN_GIT_DESCRIBE="conda"

# following recommendations of https://bioconda.github.io/contributor/guidelines.html#rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .
