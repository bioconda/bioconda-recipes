#!/bin/bash

set -x -e

PWD="$(pwd)"
SOURCE_CFG="${PWD}/path.cfg"
TARGET_CFG="${PREFIX}/etc/path.cfg"

mkdir -p "${PREFIX}/etc"
cp ${SOURCE_CFG} ${TARGET_CFG}

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root $PREFIX --path .
