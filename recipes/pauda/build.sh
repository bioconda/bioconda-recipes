#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"


export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

cp -rf pauda-1.0.1/bin $PREFIX
cp -rf pauda-1.0.1/data $PREFIX/data
cp -rf pauda-1.0.1/lib $PREFIX
chmod +x $PREFIX/bin/pauda-run
chmod +x $PREFIX/bin/pauda-build
