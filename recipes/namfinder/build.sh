#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eu -o pipefail

mkdir -p $PREFIX/bin/

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

cd $SRC_DIR/

if [ "$(uname -m)" = "x86_64" ]; then
    export CFLAGS="${CFLAGS} -msse4.2"
    export CXXFLAGS="${CXXFLAGS} -msse4.2"
fi

cmake -B build
make -j -C build

cp build/namfinder $PREFIX/bin/
