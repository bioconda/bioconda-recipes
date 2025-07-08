#!/bin/bash
set -euxo
# Compile the project
make

# Install the binaries
mkdir -p "$PREFIX/bin"
cp bin/* "$PREFIX/bin"
