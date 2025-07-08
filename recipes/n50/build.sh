#!/bin/bash
set -euxo

export CC=${CC:-gcc}
# Compile the project
make

# Install the binaries
mkdir -p "$PREFIX/bin"
cp bin/* "$PREFIX/bin"
