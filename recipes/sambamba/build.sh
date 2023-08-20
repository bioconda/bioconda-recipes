#!/bin/bash
set -eux

export CC="$CC"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
sed -e "/^CC=/d" Makefile > Makefile.new
mv Makefile.new Makefile
make CC="$CC" LIBRARY_PATH="$LIBRARY_PATH" release
# Note that checks can fail on Apple Silicon.
make check
# The 'make install' step doesn't work correctly on macOS currently.
# > make install prefix="${PREFIX}"
cp --recursive 'bin' --target-directory="${PREFIX}"
# The binary contains version number, for some reason.
mv "${PREFIX}/bin/sambamba-"* "${PREFIX}/bin/sambamba"
