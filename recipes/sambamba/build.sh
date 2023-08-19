#!/bin/bash
set -eux

export CC="$CC"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
make release
# Note that checks can fail on Apple Silicon.
make check
# The 'make install' step doesn't work correctly on macOS currently.
# > make install prefix="${PREFIX}"
mkdir -pv "${PREFIX}/bin"
# The binary contains version number, for some reason.
cp "bin/sambamba-"* "${PREFIX}/bin/sambamba"
