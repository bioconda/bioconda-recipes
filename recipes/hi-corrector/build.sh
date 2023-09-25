#!/bin/bash
set -euxo pipefail

cd "$SRC_DIR/src"
make all CC="$CC" CCMPI="mpicc"
chmod +x "$SRC_DIR/bin/"*
cp -pr "$SRC_DIR/bin" "$PREFIX"
