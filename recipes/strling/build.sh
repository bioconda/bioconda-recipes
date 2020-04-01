#!/bin/sh
cp "${CC}" "${BUILD_PREFIX}/bin/gcc"
nimble install -y --verbose
chmod a+x strling
cp strling $PREFIX/bin/strling
