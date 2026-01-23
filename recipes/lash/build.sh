#!/bin/bash

set -xeuo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX --no-track
