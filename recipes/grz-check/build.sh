#!/bin/bash -xeuo
pushd packages/grz-check
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --root "${PREFIX}" --path .
popd
