#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export ARCHFLAGS="-arch $(uname -m)"

make CC=$CC CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib"

mkdir -p $PREFIX/bin
cp bioawk $PREFIX/bin

echo "MACOSX_SDK_VERSION: "
echo $MACOSX_SDK_VERSION
echo "MACOSX_DEPLOYMENT_TARGET: "
echo $MACOSX_DEPLOYMENT_TARGET