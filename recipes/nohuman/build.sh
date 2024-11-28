#!/bin/bash
set -ex

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full cargo install -v --locked --no-track --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/nohuman"