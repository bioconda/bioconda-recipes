#!/bin/bash -euo

unamestr=`uname`

mv .cargo/config-portable.toml .cargo/config.toml

RUST_BACKTRACE=1 cargo install -v -v --verbose --root $PREFIX --path .

