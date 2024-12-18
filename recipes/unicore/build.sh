#!/bin/bash

set -x -e

SOURCE_BIN="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/unicore"
TARGET_BIN="${PREFIX}/bin/unicore"

pip install torch transformers sentencepiece protobuf
cargo build --release
cp ${SOURCE_BIN} ${TARGET_BIN}
chmod +x ${TARGET_BIN}
