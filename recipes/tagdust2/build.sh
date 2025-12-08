#!/usr/bin/env bash
set -euxo pipefail

./autogen.sh
./configure --prefix="$PREFIX"
make -j$CPU_COUNT
make install

# remove extra test binaries to reduce package size
rm -f "$PREFIX/bin/"*rtest || true
rm -f "$PREFIX/bin/tagdustiotest" || true

