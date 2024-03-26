#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export ARCHFLAGS="-arch $(uname -m)"
export MACOSX_DEPLOYMENT_TARGET=14.0

echo "MACOSX_SDK_VERSION: "
echo $MACOSX_SDK_VERSION
echo "MACOSX_DEPLOYMENT_TARGET: "
echo $MACOSX_DEPLOYMENT_TARGET

make CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin
