#!/bin/bash

set -x -e

PWD="$(pwd)"
SOURCE_BIN="${PWD}/bin/unicore"
TARGET_BIN="${PREFIX}/bin/unicore"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release
cp ${SOURCE_BIN} ${TARGET_BIN}
chmod +x ${TARGET_BIN}
