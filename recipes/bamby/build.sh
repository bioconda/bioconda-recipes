#!/bin/bash -e

export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --profile dist --root "${PREFIX}" --path .
