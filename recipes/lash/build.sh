#!/bin/bash

set -xeuo

# cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export PATH=$PREFIX/bin:$PATH

# install rustup
if ! command -v rustup &> /dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    export PATH=$HOME/.cargo/bin:$PATH
fi

rustup install nightly
rustup default nightly

RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX --no-track
