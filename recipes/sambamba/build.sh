#!/bin/bash
set -eux

# Can we get this value automatically from 'meta.yaml'?
VERSION='1.0.1'
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
mkdir -pv "${PREFIX}/bin"
cp "bin/sambamba-${VERSION}" --target-directory="${PREFIX}/bin"
# The binary contains version number, for some reason.
(
    cd "${PREFIX}/bin"
    ln -s "sambamba-${VERSION}" 'sambamba'
)
