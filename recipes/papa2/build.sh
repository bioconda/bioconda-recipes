#!/bin/bash
set -xe

# Build the C/C++ shared library using conda's compilers
export LDFLAGS="-L${PREFIX}/lib ${LDFLAGS}"
export CPATH="${PREFIX}/include:${CPATH}"
make -j${CPU_COUNT} libpapa2.so

# Install the Python package
${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv
