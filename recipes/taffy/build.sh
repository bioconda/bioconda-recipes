#!/bin/bash
set -ex

# Patch the Makefile to use cp instead of hard links
sed -i.bak 's/ln -f/cp -f/g' Makefile

# Build and install the binary
make -j ${CPU_COUNT}
mkdir -p ${PREFIX}/bin
install -v -m 755 bin/taffy ${PREFIX}/bin/

# Build and install the Python package bindings
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir