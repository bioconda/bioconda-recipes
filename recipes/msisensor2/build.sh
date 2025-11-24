#!/bin/bash
set -eu -o pipefail

mkdir -p "$PREFIX/bin"

# Copy the pre-built binary
install -v -m 0755 msisensor2 "$PREFIX/bin"

# Fix RPATH to use relative path from binary to lib directory
patchelf --set-rpath '$ORIGIN/../lib' "$PREFIX/bin/msisensor2"
