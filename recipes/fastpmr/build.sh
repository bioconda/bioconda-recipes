#!/bin/bash

export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_HOME=./.cargo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --verbose --root "$PREFIX" --path .
