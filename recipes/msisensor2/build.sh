#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin

# Copy the pre-built binary
cp msisensor2 $PREFIX/bin/msisensor2
chmod +x $PREFIX/bin/msisensor2

# Fix RPATH to use relative path from binary to lib directory
patchelf --set-rpath '$ORIGIN/../lib' $PREFIX/bin/msisensor2