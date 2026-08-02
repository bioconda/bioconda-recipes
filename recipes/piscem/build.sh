#!/bin/bash
set -euxo pipefail
unamestr=`uname`

mv .cargo/config-portable.toml .cargo/config.toml

RUST_BACKTRACE=1 cargo install -vv \
    --locked \
    --root "$PREFIX" \
    --path .
